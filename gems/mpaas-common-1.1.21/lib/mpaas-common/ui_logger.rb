# frozen_string_literal: true

# ui_logger.rb
# MpaasKit
#
# Created by quinn on 2019-01-08.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 日志模块
  # 包括文件和标准输出
  #
  module UILogger
    require 'logger'
    require 'date'

    class << self
      # 启用调试模式，日志级别为 debug
      #
      def enable_debug_mode
        logger.level = Logger::DEBUG
      end

      # 启用静默模式，标准输出不输出
      #
      def enable_silent_mode
        @silent = true
      end

      # 标准输出设备输出日志
      #
      # @param message 日志内容
      # @param color 日志添加的颜色，支持 red, green, yellow
      #
      # e.g. console("log")
      #      console("log", :red)
      #
      def console(message, color = nil)
        return if silent?

        message = send(color, message) if respond_to?(color.to_s, true)
        STDOUT.puts message
      end

      # 标准输出设备输出日志
      # 末尾不带换行
      #
      # @param message 日志内容
      # @param color 日志添加的颜色，支持 red, green, yellow
      #
      # e.g. console("log")
      #      console("log", :red)
      #
      def console_print(message, color = nil)
        return if silent?

        message = send(color, message) if respond_to?(color.to_s, true)
        Kernel.print(message)
      end

      # 调试日志
      # 双输出：日志文件和标准输出
      # 开启调试模式才会打印
      #
      # @param message 日志内容
      #
      def debug(message)
        return unless verbose?

        console message
        save_stack_info
        logger.debug message.to_s
      end

      # 信息日志
      # 双输出：日志文件和标准输出
      #
      # @param message 日志内容
      #
      def info(message)
        console message
        save_stack_info
        logger.info message.to_s
      end

      # 警告日志
      # 双输出：日志文件和标准输出
      #
      # @param message 日志内容
      #
      def warning(message)
        console(message, :yellow)
        save_stack_info
        logger.warn message.to_s
      end

      # 错误日志
      # 双输出：日志文件和标准输出
      #
      # @param message 日志内容
      #
      def error(message)
        console(message, :red)
        save_stack_info
        logger.error message.to_s
      end

      # 异常日志
      # 双输出：日志文件和标准输出
      #
      # @param exception 异常实例
      #
      def exception(exception)
        console(exception.message, :red)
        console exception.backtrace if verbose?
        save_stack_info
        logger.error exception.message
        logger.error "\n\t" + exception.backtrace.join("\n\t")
      end

      # 默认级别日志
      # 双输出：日志文件和标准输出
      #
      # @param message 日志内容
      #
      def print(message)
        console message
        save_stack_info
        logger << message.to_s
      end

      # 段落info日志
      #
      # @param [String] message
      #
      def section_info(message)
        info('>>> ' + message)
      end

      # 日志文件名
      #
      def log_file_name
        "#{prog_name}.log"
      end

      private

      # 调试模式
      #
      # @return [Bool]
      #
      def verbose
        logger.level == Logger::DEBUG
      end
      alias verbose? verbose

      # 静默模式
      #
      # @return [Bool]
      #
      def silent
        @silent || false
      end
      alias silent? silent

      # 文件日志实例
      #
      def logger
        @logger ||= create_logger
      end

      # 创建文件日志实例
      # @return logger 实例
      #
      def create_logger
        FileUtils.mkdir_p(LocalPath.log_dir)
        # 删除过期日志文件
        expired_log_files.each(&FileUtils.method(:rm))
        # 配置 logger
        logger = Logger.new(LocalPath.log_dir + log_file_name, 'daily')
        logger.progname = prog_name
        logger.level = Logger::INFO
        logger.formatter = proc do |severity, datetime, progname, msg|
          "\n[#{datetime}][#{progname}][#{severity}](#{@location}): #{msg}"
        end
        logger
      end

      # 标准输出设备打印绿色日志
      #
      # @param string 日志内容
      #
      def green(string)
        "\033[0;32m#{string}\e[0m"
      end

      # 标准输出设备打印红色日志
      #
      # @param string 日志内容
      #
      def red(string)
        "\033[0;31m#{string}\e[0m"
      end

      # 标准输出设备打印黄色日志
      #
      # @param string 日志内容
      #
      def yellow(string)
        "\033[0;33m#{string}\e[0m"
      end

      # 保存调用的堆栈位置
      #
      def save_stack_info
        trace = caller_locations(2, 1)[0]
        @location = "#{File.basename(trace.path)} #{trace.lineno}"
      end

      # 模块名
      #
      def prog_name
        File.basename($PROGRAM_NAME, '.rb')
      end

      # 过期的日志文件
      #
      # @return 过期的日志文件路径数组
      #
      def expired_log_files
        Dir.entries(LocalPath.log_dir).select do |entry|
          entry =~ /#{log_file_name}\.\d{8}$/ &&
            Date.strptime(entry.split('.').last, '%Y%m%d') < expired_date
        end.map(&LocalPath.log_dir.method(:+))
      end

      EXPIRE_TIME = 7 # 日志过期时间 7 天

      # 过期时间
      #
      def expired_date
        now = Time.now
        Date.new(now.year, now.month, now.day) - EXPIRE_TIME
      end
    end
  end
end
