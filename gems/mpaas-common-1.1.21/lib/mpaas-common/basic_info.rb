# frozen_string_literal: true

# basic_info.rb
# MpaasKit
#
# Created by quinn on 2019-01-10.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 全局基础信息
  #
  class BasicInfo
    # 单例方法
    #
    # @return [BasicInfo]
    #
    def self.instance
      @instance ||= new
    end

    def initialize
      # v4 版本
      @active_v4 = false
    end

    # 解析命令行参数
    #
    # @param options [Hash] 命令行参数字典
    #
    def parse_options(options)
      @project_path = Pathname.new(options.fetch(:path))
      @project_name = options.fetch(:name)
      config_file = options.fetch(:config)
      @app_info = JSON.parse(File.read(config_file)) if File.exist?(config_file)
      @active_target = options.fetch(:target, @project_name)
      @organization = options.fetch(:org, 'Alibaba')
      @class_prefix = options.fetch(:clz_prefix, '')
      @copy_mode = options.fetch(:copy, false)
    end

    attr_reader :project_name,  # 工程名
                :project_path,  # 工程路径
                :active_target, # 处理的当前工程 target
                :organization,  # 公司组织名称
                :class_prefix,  # 类名前缀
                :copy_mode,     # copy 模式
                :app_info       # 应用信息（云端配置数据）

    attr_accessor :active_v4    # 激活 4.x 基线模式

    # 提供外部引入 mixin
    #
    module Mixin
      def basic_info
        BasicInfo.instance
      end
    end
  end
end
