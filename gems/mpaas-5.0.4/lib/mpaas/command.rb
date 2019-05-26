# frozen_string_literal: true

# command.rb
# MpaasKit
#
# Created by quinn on 2019-01-14.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 命令执行的错误类
  #
  class CommandError < RuntimeError
    attr_accessor :error_cmd
    def initialize(message, cmd = nil)
      super(message)
      self.error_cmd = cmd
    end
  end

  # 命令的基类
  # [!!] 所有子命令必须继承该类
  #
  class Command
    include Config::Mixin

    # 命令的加载路径
    # e.g. command/xxx/xxx
    #
    def self.load_path
      to_s.split('::')[1..-1].map!(&:downcase).join('/')
    end

    # 自动加载命令
    #
    # @return 命令实例
    #
    def self.load
      cmd_dir = Pathname.new(__FILE__).join('..') + load_path
      cmd_list = []
      if cmd_dir.exist?
        Dir.foreach(cmd_dir) do |entry|
          next unless entry =~ /(.*)\.rb$/
          # 导入文件
          require_relative "#{load_path}/#{entry}"
          # 类名未定义不处理
          const = "#{self}::#{entry.chomp('.rb').capitalize}"
          next unless Object.const_defined?(const)
          # load 并且实例化命令
          clz = Object.const_get(const)
          cmd_list << clz.load if clz.superclass == self
        end
      end
      new(cmd_list)
    end

    def initialize(child_cmd_list = nil)
      @child_cmd_list = child_cmd_list || []
    end

    # 命令的名称
    #
    def name
      @name ||= self.class.to_s.split('::')[-1].downcase
    end

    # 命令使用方法说明
    #
    # @return 说明字符串
    #
    def usage
      parser.help
    end

    # 命令的简单说明
    # 子类定义
    #
    def summary
      "#{config.progname} command line tool"
    end

    # 执行错误 assert
    # 成功继续，失败抛出异常
    #
    # @param condition 判断条件
    # @param message 条件失败的消息
    #
    def assert(condition, message)
      raise CommandError.new(message, self) unless condition

      yield if block_given?
    end

    # 定义解析器
    # 子类定义，其中 banner 和 commands 有统一的赋值，如有特殊要求可以自行赋值覆盖
    # 普通命令只需设置 description 和 argument 参数
    #
    # @param parser 解析器实例
    #
    def define_parser(parser)
      parser.description = summary
      parser.add_argument('--version', :desc => "Show version number of '#{config.progname}' tool") do
        UILogger.console config.version
        exit 0
      end
    end

    # 子命令集
    #
    attr_accessor :child_cmd_list

    # 执行命令
    # 子类需要自己实现
    # [!!] 子类需先调用 super(argv)
    #
    # @param argv 待解析的命令行参数
    #
    def run(argv)
      config.argv = argv
      if child_cmd_list.empty? # 子命令执行
        actual_action(argv)
      else # 递归解析下一级命令
        parser.order!(argv)
        assert(!argv.empty? || child_cmd_list.empty?, 'missing child command')
        cmd_name = argv.shift
        cmd = child_cmd_list.find { |child_cmd| child_cmd.name == cmd_name }
        assert(cmd, "invalid command: '#{cmd_name}'") { cmd.run(argv) }
      end
    end

    protected

    # 命令行解析的参数
    #
    # @return [Hash]
    #
    def options
      @options ||= {}
    end

    # 打印结果信息
    #
    # @param [Bool] process_result
    # @param [String] success_msg
    # @param [String] error_message
    #
    def print_result_message(process_result, success_msg, error_message, error_code)
      if process_result
        UILogger.info(success_msg)
      else
        UILogger.error(error_message)
        exit(error_code)
      end
    end

    private

    # 解析器实例
    #
    def parser
      @parser ||= Parser.new do |parser|
        # 统一赋值 banner 和 commands
        banner = self.class.load_path.split('/')[1..-1].unshift(config.progname)
        banner << '[COMMAND]' unless child_cmd_list.empty?
        banner << '[OPTIONS]'
        parser.banner = banner
        parser.commands = child_cmd_list
        define_parser(parser)
      end
    end

    # 实际命令的执行
    #
    # @param [Array] argv
    #
    def actual_action(argv)
      parser.parse!(argv)
      assert(*parser.validate_require_options)
      UILogger.debug("当前执行命令: #{config.argv.join(' ')}")
      UILogger.debug('------------------------------')
    end
  end
end
