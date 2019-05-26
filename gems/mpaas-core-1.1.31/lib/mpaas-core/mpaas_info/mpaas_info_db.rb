# frozen_string_literal: true

# mpaas_info_db.rb
# MpaasKit
#
# Created by quinn on 2019-01-11.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # mpaas 信息内存数据库
  #
  class MpaasInfoDB
    require_relative 'mpaas_info_db_source'

    def initialize
      # 模块信息数据表，表中每条记录为 DBModuleRecord 类型
      @module_info_table = []
    end

    # 创建数据库
    #
    # @return [MpaasInfoDB]
    #
    def self.create
      new
    end

    # 数据是否为空
    #
    # @return [Bool]
    #
    def empty?
      @module_info_table.empty?
    end

    # 插入数据（添加模块）
    #
    # @param modules [Array<ModuleObject>] 插入的模块数组
    # @param target 模块所在的 target 名称
    #
    def insert(modules, target)
      modules.each do |module_obj|
        # 插入新记录
        @module_info_table << DBModuleRecord.new(module_obj.name, target, module_obj, module_obj)
      end
    end

    # 删除数据
    #
    # @param modules [Array<ModuleObject>] 删除的模块数组
    # @param target 模块所在的 target 名称
    #
    def delete(modules, target)
      modules.each do |module_obj|
        install_modules = all(->(record) { record.target == target }).map(&:module_obj) || []
        existing_record = all(->(record) { record.target == target && record.name == module_obj.name }).shift
        if existing_record.nil?
          has_included = !install_modules.select { |mod| mod.include?(module_obj) }.empty?
          raise "无法找到待删除的模块: #{module_obj.name}" unless has_included
        else
          # 设置为 nil 即删除
          existing_record.update_to(nil)
        end
      end
    end

    # 更新数据
    #
    # @param modules [Array<ModuleObject>] 更新的模块数组
    # @param target 模块所在的 target 名称
    #
    def update(modules, target)
      modules.each do |module_obj|
        existing_record = all(->(record) { record.target == target && record.name == module_obj.name }).shift
        if existing_record.nil?
          # 插入新记录, 标记是新增
          @module_info_table << DBModuleRecord.new(module_obj.name, target, nil, module_obj)
        else
          # 存在，直接更新
          existing_record.update_to(module_obj)
        end
      end
    end

    # 查找数据
    #
    # @param method_list [Array<Symbol>]
    #                    查找的数据类型, 支持批量查找
    #                    :all/:modules/:all_frameworks/:all_baselines
    #                    :header/:pch/:categories
    #                    :mpaas_frameworks/:mpaas_resources
    #                    :sys_frameworks/:sys_libraries
    # @param condition [Proc] 查找数据条件
    # @return [Array<Array>]
    #         命中的数组，支持批量，具体内容看各查找方法的返回值
    #
    def select(method_list, condition = nil)
      Array(method_list).map { |sym| method(sym).call(condition) }
    end

    # 设置冲突的工程包对象
    #
    # @param condition [Proc] 查找数据条件
    #
    def setup_context(condition)
      records = all(condition)
      conflict_frameworks = ModuleConfig.conflict_frameworks do |conflict_name|
        record = records.find { |r| r.module_obj.find_framework_obj(conflict_name) }
        [record.module_obj.find_framework_obj(conflict_name), record.operation_type] unless record.nil?
      end
      UILogger.debug("存在冲突的库: #{conflict_frameworks.map(&:name).join(',')}") unless conflict_frameworks.empty?
      @conflict_frameworks = conflict_frameworks.flat_map(&:framework_files).map(&File.method(:basename))
      @conflict_resources = conflict_frameworks.flat_map(&:resource_files).map(&File.method(:basename))
    end

    private

    # 查找所有符合条件的记录
    #
    # @param condition [Proc] 查找数据条件
    # @return [Array<DBModuleRecord>]
    #
    def all(condition)
      @module_info_table.select { |record| condition&.call(record) }
    end

    # 查找所有的模块和版本信息
    #
    # @param condition [Proc] 查找数据条件
    # @return [Hash] 名称版本对应关系
    #         e.g. { "Module1": "1.0.1", "Module2": "2.0.1", ... }
    #
    def modules(condition)
      all(condition).map { |record| [record.name, record.module_obj.version] }.to_h
    end

    # 查找所有模块的工程包的信息
    #
    # @param condition [Proc] 查找数据条件
    # @return [Hash] 名称版本对应关系
    #         e.g. { "Module1": { "Framework1": "1.0.1", "Framework2": "2.0.1" }, ... }
    #
    def all_frameworks(condition)
      all(condition).map { |record| [record.name, record.module_obj.frameworks_version_info] }.to_h
    end

    # 查找所有模块的基线信息
    #
    # @param condition [Proc] 查找数据条件
    # @return [Hash] 名称基线对应关系
    #         e.g. { "Module1": "baseline1", "Module2": "baseline2", ... }
    #
    def all_baselines(condition)
      all(condition).map { |record| [record.name, record.module_obj.baseline] }.to_h
    end
  end
end
