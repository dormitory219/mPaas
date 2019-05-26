# frozen_string_literal: true

# command_executor.rb
# MpaasKit
#
# Created by quinn on 2019-01-09.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # shell 命令执行错误
  #
  class CommandExecError < StandardError
    def initialize(message, *content)
      super(message)
      @content = content
    end

    def message
      super + ': ' + @content.join("\n")
    end
  end

  # shell 命令工具
  #
  module CommandExecutor
    require 'English'

    class << self
      # 执行命令
      #
      # @param [String] cmd shell 命令
      # @param [Bool] debug
      # @return [Array<String, ProcessStatus>]
      #         数组两个元素，第一个为输出内容，第二个为子进程执行结果
      #
      def exec(cmd, debug = true)
        UILogger.debug("执行命令: #{cmd}") if debug
        output = `#{cmd}`
        output = '执行失败! ' + output unless $CHILD_STATUS.success?
        [output.strip, $CHILD_STATUS]
      end
    end
  end
end
