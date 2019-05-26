# frozen_string_literal: true

# config.rb
# MpaasKit
#
# Created by quinn on 2019-01-14.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 全局的配置
  #
  class Config
    # 是否屏蔽标准输出
    #
    attr_reader :silent
    alias silent? silent

    # 命令应用名称
    #
    attr_reader :progname

    # 命令的总输入参数
    #
    attr_reader :argv

    # 设置命令总输入参数
    # 只保存一次
    #
    # @param [Array] argv
    #
    def argv=(argv)
      @argv = argv.dup if @argv.nil?
    end

    # ------------------------
    # 工具配置
    # ------------------------

    # 是否为调试模式
    #
    # @return [Bool]
    #
    def verbose
      @verbose && !silent
    end
    alias verbose? verbose

    # 设置调试模式
    #
    # @param verbose [Bool]
    #
    def verbose=(verbose)
      @verbose = verbose
      UILogger.enable_debug_mode if verbose?
    end

    # 设置静默模式
    #
    # @param silent [Bool]
    #
    def silent=(silent)
      @silent = silent
      UILogger.enable_silent_mode if silent
      UILogger.enable_debug_mode if verbose?
    end

    # 工具版本号
    #
    def version
      Mpaas::VERSION
    end

    def self.instance
      @instance ||= new
    end

    def initialize
      @verbose = false
      @silent = false
      @progname = File.basename($PROGRAM_NAME, '.rb')
    end

    # 支持配置重置
    #
    class << self
      attr_writer :instance
    end

    # 提供外部引入 mixin
    #
    module Mixin
      # 配置文件单例
      #
      # @return [Config]
      #
      def config
        Config.instance
      end

      # 首次加载
      #
      def self.included(_mod)
        MpaasEnv.load_from_config
      end
    end
  end
end
