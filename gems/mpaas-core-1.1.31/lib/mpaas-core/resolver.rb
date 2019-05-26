# frozen_string_literal: true

# resolver.rb
# MpaasKit
#
# Created by quinn on 2019-01-11.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # mpaas 工程框架解析器
  #
  class Resolver
    include BasicInfo::Mixin

    # 初始化
    #
    # @param project 工程对象
    #
    def initialize(project)
      @project = project
      @mpaas_info = nil
      @project.parse_mpaas_targets = @project.targets.reject { |t| resolve_module_versions_info(t).nil? }
    end

    # 解析当前 mpaas 工程信息，并生成对应框架
    #
    # @param &block 回调 block 解析模块列表
    # @return [MpaasFramework] 生成的 mpaas 框架
    #
    def resolve
      # 非 mpaas 工程，直接返回空
      return nil unless @project.mpaas_file.exist?
      mpaas_info = resolve_mpaas_info { |versions_by_module, baseline| yield(versions_by_module, baseline) }
      # 创建当前工程框架
      MpaasFramework.load_project_info(@project, mpaas_info)
    end

    # 解析当前 mpaas 工程信息
    #
    # @param &block 回调 block 解析模块列表
    # @return [MpaasInfo] 解析的 mpaas info
    #
    def resolve_mpaas_info
      # 非 mpaas 工程，直接返回空
      return nil unless @project.mpaas_file.exist? || !block_given?
      # 解析基线版本
      baseline_version = resolved_current_baseline
      # 获取所有 target 的模块信息，不同 target 使用的版本相同，只是数量不同
      modules_by_target = config_info[Constants::MPAAS_FILE_TARGETS_KEY].map do |target_name, target_info|
        # v4 版本 block 回调两个参数都是字典, v5 版本回调一个字典，一个字符串
        [target_name, yield(target_info[Constants::MPAAS_FILE_VERSIONS_KEY],
            target_info[Constants::MPAAS_FILE_BASELINE_KEY])]
      end.compact.to_h
      # 转换成 mpaas info
      mpaas_info = MpaasInfo.new(@project, baseline_version)
      mpaas_info.setup(modules_by_target)
      mpaas_info
    end

    # 解析模块的版本信息
    # 原始数据
    #
    # @param [String] target_name
    # @return [Hash] 模块名版本号字典
    # e.g. { "Module1": "x.x.x", "Module2": "x.x.x"} v4
    #      { "Module1": { "Framework1": "x.x.x", ...}, ... } v5
    #
    def resolve_module_versions_info(target_name)
      # 非 mpaas 工程，不解析
      return nil unless @project.mpaas_file.exist?
      targets = config_info[Constants::MPAAS_FILE_TARGETS_KEY]
      return nil unless targets.key?(target_name)
      # 直接提取 versions 字段信息
      targets[target_name].fetch(Constants::MPAAS_FILE_VERSIONS_KEY, nil)
    end

    # 解析是否为 copy 模式
    #
    # @return [Bool]
    #
    def resolve_copy_mode
      config_info[Constants::MPAAS_FILE_COPY_KEY]
    end

    # 解析模块的基线版本信息
    #
    # @param [String] target_name
    # @return [String,Hash]
    #
    def resolve_module_baseline_info(target_name)
      # 非 mpaas 工程，不解析
      return nil unless @project.mpaas_file.exist?
      targets = config_info[Constants::MPAAS_FILE_TARGETS_KEY]
      return nil unless targets.key?(target_name)
      # 直接提取 baseline 字段信息
      targets[target_name].fetch(Constants::MPAAS_FILE_BASELINE_KEY, nil)
    end

    # 解析出工程中集成的所有模块名称
    # 多个target取并集，原始数据
    #
    # @return [Array]
    #
    def resolve_all_installed_modules
      module_info_hash = {}
      @project.targets.each do |target|
        module_info_hash.update(resolve_module_versions_info(target))
      end
      module_info_hash.keys
    end

    # 解析当前工程的基线版本号
    #
    # @return [String]
    #
    def resolved_current_baseline
      # 非 mpaas 工程，直接返回空
      return nil unless @project.mpaas_file.exist?
      # 提取 baseline 字段，如果没有当前 target 信息，就直接返回 nil
      baseline_info = config_info.fetch(Constants::MPAAS_FILE_TARGETS_KEY)
                                 .fetch(@project.active_target, {})
                                 .fetch(Constants::MPAAS_FILE_BASELINE_KEY, nil)
      if @project.targets.count > 1
        # 多个 target， 如果当前 target 未集成，选择其它集成 mpaas 的 target 基线版本
        baseline_info ||= config_info.fetch(Constants::MPAAS_FILE_TARGETS_KEY)
                                     .fetch(@project.mpaas_targets.first, {})
                                     .fetch(Constants::MPAAS_FILE_BASELINE_KEY, nil)
      end
      # 兼容 v4
      baseline_info.is_a?(Hash) ? baseline_info.values.uniq.first : baseline_info
    end

    private

    # mpaas 配置信息
    #
    # @return [Hash]
    #
    def config_info
      @config_info ||= @project.mpaas_file.read
    end
  end
end
