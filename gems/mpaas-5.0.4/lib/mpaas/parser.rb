# frozen_string_literal: true

# parser.rb
# MpaasKit
#
# Created by quinn on 2019-01-14.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 参数解析 wrapper
  #
  class Parser
    require_relative 'parser/argument'

    INDENT = ' ' * 4
    WIDTH = 32

    def initialize
      @banner = []        # 命令说明
      @description = ''   # 命令描述
      @commands = []      # 子命令集
      @arguments = []     # 命令参数
      yield self if block_given?
    end

    # parser 帮助日志
    #
    def help
      optparser.help
    end
    alias to_s help

    # 解析
    #
    def parse!(argv)
      optparser.parse!(argv)
      parse_positioned_arguments(argv)
      # 统一赋值参数
      (@arguments + default_arguments).each(&:call_setting_argument)
    end

    # 必要参数校验
    #
    # @return 数组 [是否校验通过, 错误信息]
    #
    def validate_require_options
      missing_arg = @arguments.select(&:missing?).map { |arg| "'#{arg.title}'" }.join(' ')
      [missing_arg.empty?, missing_arg.empty? ? nil : "missing required argument: #{missing_arg}"]
    end

    # 按顺序解析参数
    #
    # @param argv 当前解析的命令行参数
    #
    def order!(argv)
      optparser.order!(argv)
      # 统一赋值参数
      (@arguments + default_arguments).each(&:call_setting_argument)
    end

    # 设置用法提示数组, 命令描述, 子命令集数组
    attr_writer :banner, :description, :commands

    # 设置解析参数，并接收解析后的参数
    #
    # @param *opts 解析的参数
    # @param desc 参数描述内容 默认为 nil
    # @param require 是否为必须参数 默认为 false
    # @param default lambda 表达式 获取参数默认值 默认 nil
    # @param &set_action 解析后设置参数值的回调 block 默认参数也通过该 block 回调
    #
    # e.g.
    #   add_argument('NAME', desc: 'positioned argument') { |arg| puts arg }
    #   add_argument('-u', require: true, default: -> { 1 }) { |arg| @u = arg }
    #   add_argument('-t', '--test ABC', desc: 'instruction') do |arg|
    #     puts 'receive argument' + arg
    #   end
    #
    def add_argument(*opts, desc: nil, require: false,
                     default: nil, &set_action)
      @arguments << Argument.new(*opts) do |arg|
        arg.desc = desc
        arg.default = default
        arg.setting_action = set_action
        arg.require! if require
        # 添加位置参数占位符
        @banner << arg.placeholder unless arg.option?
      end
    end

    private

    include Config::Mixin

    # 创建 optparser
    #
    def optparser
      @optparser ||= OptionParser.new do |parser|
        parser.banner = 'Usage:'
        section_banner(parser)
        section_description(parser)
        section_commands(parser)
        section_options(parser)
        section_positioned_arguments(parser)
      end
    end

    # 定义解析器展示的 banner
    #
    def section_banner(parser)
      parser.separator INDENT + '$ ' + @banner.join(' ') unless @banner.empty?
    end

    # 定义解析器展示的描述
    #
    def section_description(parser)
      return if @description.empty?

      parser.separator ''
      parser.separator INDENT + @description
    end

    # 定义解析器展示的子命令
    #
    def section_commands(parser)
      return if @commands.empty?

      parser.separator ''
      parser.separator 'Commands:'
      @commands.each do |cmd|
        parser.separator INDENT + cmd.name.ljust(WIDTH) + ' ' + cmd.summary
      end
    end

    # 定义解析器展示的参数
    #
    def section_options(parser)
      parser.separator ''
      parser.separator 'Options:'
      custom_options(parser)
      general_options(parser)
    end

    # 定义解析器接收的命令自定参数
    #
    def custom_options(parser)
      @arguments.select(&:option?).each do |arg|
        parser.on(*arg.opts, &arg.method(:parse_argument))
      end
    end

    # 定义解析器接收的命令通用参数
    #
    def general_options(parser)
      default_arguments.each do |arg|
        parser.on(*arg.opts, &arg.method(:parse_argument))
      end
    end

    # 定义解析器接收的固定参数
    #
    def section_positioned_arguments(parser)
      @arguments.each do |arg|
        next if arg.option?

        left = INDENT + arg.placeholder.ljust(WIDTH) + ' '
        parser.separator left + arg.desc + ' [Required]'
      end
    end

    # 所有命令的默认参数
    #
    # @return Argument 数组
    #
    def default_arguments
      @default_arguments ||= [
        Argument.new('-h', '--help') do |arg|
          arg.desc = 'Show help message of specified command'
          arg.setting_action = proc do
            UILogger.console optparser
            exit
          end
        end,
        Argument.new('--verbose') do |arg|
          arg.desc = 'Show more debugging information'
          arg.setting_action = proc { |verbose| config.verbose = verbose }
        end,
        Argument.new('--silent') do |arg|
          arg.desc = 'Silent mode (output nothing)'
          arg.setting_action = proc { |silent| config.silent = silent }
        end
      ]
    end

    # 解析固定参数
    #
    # @param argv 剩余未解析的参数
    #
    def parse_positioned_arguments(argv)
      @arguments.reject(&:option?).each do |arg|
        break if argv.empty?
        # 取值判空
        value = arg.repeatable? ? argv.shift(argv.count) : argv.shift
        next if value.nil? || value.empty?
        # 保存参数值
        arg.parse_argument(value)
      end
    end
  end
end
