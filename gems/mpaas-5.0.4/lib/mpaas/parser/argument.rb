# frozen_string_literal: true

# argument.rb
# MpaasKit
#
# Created by quinn on 2019-01-14.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class Parser
    # 命令行参数类
    # 包括位置参数和选项参数
    #
    class Argument
      attr_reader :require # 是否为必须参数
      alias require? require

      attr_accessor :desc # 参数描述
      attr_writer :setting_action # 参数赋值回调 block
      attr_writer :default # 参数获取默认值 lambda

      # 初始化
      #
      # @param *param 参数配置
      #
      # e.g.
      #     new('-v', '--version') do |arg|
      #       arg.desc = 'version'
      #       arg.default = '1.0.0'
      #       arg.setting_action = { |arg| puts arg }
      #       arg.require!
      #     end
      #
      def initialize(*param)
        @param = param
        @desc = nil
        @default = nil
        @value = nil # 参数解析的值
        @setting_action = nil
        @require = !option?
        @checked = false # 是否参数已解析到
        yield self if block_given?
      end

      # 设置为必须参数
      #
      def require!
        @require = true
      end

      # 参数标题
      #
      def title
        @param.first
      end

      # 帮助中展示的占位符
      # 选项参数为 title，位置参数为 '<title>'/'<title>...'
      #
      def placeholder
        return title if option?

        repeatable? ? "<#{title.chomp('...')}>..." : "<#{title}>"
      end

      # 解析后设置参数值
      #
      # @param arg 解析的参数值
      #
      def parse_argument(arg)
        @checked = true # 标记参数已设置
        @value = arg
      end

      # 执行设置参数回调
      # 如果解析了参数就回调该参数，否则就取默认值 lambda 返回的值
      #
      def call_setting_argument
        return if @setting_action.nil? || (!checked? && @default.nil?)

        @setting_action.call(@value.nil? ? @default.call : @value)
      end

      # 位置参数是否允许重复输入
      #
      def repeatable?
        !option? && !@param.select { |opt| opt.end_with? '...' }.empty?
      end

      # 必须参数是否缺失
      # 必须参数 && 未解析
      #
      def missing?
        require? && !checked?
      end

      # 是否为选项参数
      #
      def option?
        !@param.select { |opt| opt.is_a?(String) && opt.start_with?('-', '--') }.empty?
      end

      # 选项参数完全配置
      #
      # @return 数组
      # e.g. ['-v', '--version', 'version']
      #
      def opts
        @param + [@desc.to_s + (require? ? ' [Required]' : '')]
      end

      private

      # 必要参数是否已填
      #
      attr_accessor :checked
      alias checked? checked
    end
  end
end
