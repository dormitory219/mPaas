# frozen_string_literal: true

# mpaas_info.rb
# MpaasKit
#
# Created by quinn on 2019-01-11.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # mpaas 框架信息
  #
  class MpaasInfo
    require_relative 'mpaas_info/db_module_record'
    require_relative 'mpaas_info/mpaas_info_db'

    include BasicInfo::Mixin

    # mpaas info 名称
    #
    # @return [String]
    #
    def name
      Constants::MPAAS_FILE_NAME
    end

    # 初始化
    #
    # @param project 工程对象
    # @param baseline 基线版本
    #
    def initialize(project, baseline)
      @project = project
      @baseline = baseline
      @info_db = MpaasInfoDB.create
    end

    # 建立各 target 的模块信息
    #
    # @param modules_by_target 各 target 对应的模块信息
    # e.g. {"Target1": [ModuleObject1, ModuleObject2, ...], "Target2": [ModuleObject],...}
    #
    def setup(modules_by_target)
      modules_by_target.each do |target_name, modules|
        @info_db.insert(modules, target_name)
      end
    end

    # 更新框架信息
    #
    # @param modules [Array<ModuleObject>] 模块信息数组
    # @param [String] baseline 更新的基线版本号
    # @param remove [Bool] 是否移除
    #
    def update(modules, baseline, remove = false)
      UILogger.info("更新 mPaaS info: #{baseline}")
      if remove
        modules = real_del_modules(modules) if basic_info.active_v4
        @info_db.delete(modules, @project.active_target)
      else
        # 更新基线
        @baseline = baseline
        @info_db.update(modules, @project.active_target)
      end
    end

    # 实际删除的模块
    #
    # @param [Array<ModuleObject>] modules
    # @return [Array<ModuleObject>]
    #
    def real_del_modules(modules)
      records = @info_db.select(:all, ->(record) { record.target == @project.active_target }).shift
      modules += find_isolated_module(records.map(&:name), modules)
      # 从所有安装的模块中找出删除的模块
      modules.select { |m| records.map(&:name).include?(m.name) && can_remove?(m) }
    end

    # 是否为空
    #
    # @return [Bool]
    #
    def empty?
      @info_db.empty?
    end

    # 取 target 信息
    #
    # @param target_name [String] target 名称
    # @return [TargetMpaasInfo] 对应 target 的 mpaas 框架信息
    #
    def [](target_name)
      # 如果数据为空，返回一个空的
      return MpaasTargetInfo.new(@baseline) if @info_db.empty?
      # 组装成 target info
      generate_target_info(->(record) { record.target == target_name })
    end

    # mpaas 信息输出为配置内容
    #
    # @return [Hash] json 对象格式
    #
    def dump
      target_info_hash = @project.mpaas_targets.map do |name|
        info = self[name]
        # 一个模块都没有，说明该 target 已经不是 mpaas target 了
        [name, info.dump] unless info.empty?
      end.compact.to_h
      {
        Constants::MPAAS_FILE_NOTICE_KEY => 'This file is maintained by MPaaS automatically.',
        Constants::MPAAS_FILE_PROJECT_KEY => @project.name,
        Constants::MPAAS_FILE_COPY_KEY => basic_info.copy_mode,
        Constants::MPAAS_FILE_TARGETS_KEY => target_info_hash,
        Constants::MPAAS_FILE_RECENT_KEY => @project.active_target
      }
    end

    private

    # 找到孤立的模块
    #
    # @param [Array<String>] installed_modules
    # @param [Array<ModuleObject>] modules
    # @return [Array<ModuleObject>]
    #
    def find_isolated_module(installed_modules, modules)
      modules.map do |mod|
        # 在依赖中找出非component模块，并且引用只有当前删除的模块/引用其它模块未安装
        mod.dependencies.select do |d|
          # 去除本模块和不在已安装模块中的
          remove_refers = d.refers.reject { |r| !installed_modules.include?(r.name) || r.name == mod.name }
          !d.component? && remove_refers.empty?
        end
      end.flatten
    end

    # 生成 target info
    #
    # @param [Proc] target_condition
    # @return [MpaasTargetInfo]
    #
    def generate_target_info(target_condition)
      target_info = MpaasTargetInfo.new(@baseline)
      @info_db.setup_context(target_condition) unless basic_info.active_v4
      # 从DB取数据target信息
      %i[header categories pch mpaas_frameworks mpaas_resources sys_frameworks sys_libraries].each do |sym|
        getter = sym
        setter = (sym.to_s + '=').to_sym
        target_info.method(setter).call(@info_db.select(getter, target_condition).shift)
      end
      existing_conditions = ->(record) { target_condition.call(record) && record.operation_type != :del }
      target_info.versions_by_module = @info_db.select(:modules, existing_conditions).shift
      target_info.frameworks_info = @info_db.select(:all_frameworks, existing_conditions).shift
      target_info.baseline_info = @info_db.select(:all_baselines, existing_conditions).shift
      target_info
    end

    # 是否可以删除
    #
    # @param module_object [ModuleObject] 模块对象
    # @return [Bool]
    #
    def can_remove?(module_object)
      records = @info_db.select(:all, ->(record) { record.name == module_object.name }).shift
      # 如果只有当前 target 使用该模块，并且是非必要模块可以删除
      records.size == 1 &&
        records.first.target == @project.active_target &&
        !required_modules.include?(records.first.name)
    end

    # 必要的模块
    #
    # @return [Array<String>]
    #
    def required_modules
      if @project.using_mobile_framework?(@project.active_target)
        [ModuleConfig.module_name('APMobileFramework')]
      else
        []
      end
    end
  end
end
