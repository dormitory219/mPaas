# frozen_string_literal: true

# mpaas_target_info.rb
# MpaasKit
#
# Created by quinn on 2019-01-11.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # mpaas target 框架信息
  #
  class MpaasTargetInfo
    include BasicInfo::Mixin

    attr_reader   :versions_by_module # 模块版本字典
    attr_accessor :header,            # 头文件数据
                  :pch,               # pch文件数据
                  :categories,        # 分类文件数据
                  :mpaas_frameworks,  # mpaas framework 数据
                  :mpaas_resources,   # mpaas 资源文件数据
                  :sys_frameworks,    # 系统库数据
                  :sys_libraries,     # 系统 lib 数据
                  :frameworks_info,   # 工程包信息 v5新增
                  :baseline_info      # 每个模块的 baseline

    # 初始化
    #
    # @param baseline 基线版本
    #
    def initialize(baseline)
      @baseline = baseline
      @header = []
      @pch = []
      @categories = []
      @mpaas_frameworks = []
      @mpaas_resources = []
      @sys_frameworks = []
      @sys_libraries = []
      @versions_by_module = {}
    end

    def versions_by_module=(hash)
      @versions_by_module = hash.each { |key, value| hash[key] = @baseline if value.nil? }
    end

    # 是否模块数据为空
    #
    # @return [Bool]
    #
    def empty?
      @versions_by_module.empty?
    end

    # target 信息输出为配置内容
    #
    # @return [Hash] json 对象格式
    #
    def dump
      # 如果没有模块信息返回空的
      # return {} if versions_by_module.empty?
      # 兼容 v4
      basic_info.active_v4 ? info_hash_old : info_hash
    end

    # 配置信息 v4
    #
    # @return [Hash]
    #
    def info_hash_old
      frameworks = mpaas_frameworks.reject { |_, _, op| op == :del }.map { |name, _, _| name }
      resources = mpaas_resources.reject { |_, _, op| op == :del }.map { |name, _, _| name }
      {
        Constants::MPAAS_FILE_AUTHOR_KEY => SystemInfo.user_name,
        Constants::MPAAS_FILE_TIME_KEY => Time.now.strftime('%Y/%m/%d %H:%M:%S'),
        Constants::MPAAS_FILE_VERSIONS_KEY => versions_by_module,
        Constants::MPAAS_FILE_BASELINE_KEY => baseline_info,
        Constants::MPAAS_FILE_FRAMEWORK_KEY => frameworks,
        Constants::MPAAS_FILE_RESOURCE_KEY => resources
      }
    end

    # 配置信息 v5
    #
    # @return [Hash]
    #
    def info_hash
      frameworks = mpaas_frameworks.reject { |_, _, op| op == :del }.map { |name, _, _| name }
      resources = mpaas_resources.reject { |_, _, op| op == :del }.map { |name, _, _| name }
      {
        Constants::MPAAS_FILE_AUTHOR_KEY => SystemInfo.user_name,
        Constants::MPAAS_FILE_TIME_KEY => Time.now.strftime('%Y/%m/%d %H:%M:%S'),
        Constants::MPAAS_FILE_VERSIONS_KEY => frameworks_info,
        Constants::MPAAS_FILE_BASELINE_KEY => @baseline,
        Constants::MPAAS_FILE_FRAMEWORK_KEY => frameworks,
        Constants::MPAAS_FILE_RESOURCE_KEY => resources
      }
    end
  end
end
