# frozen_string_literal: true

# entry.rb
# MpaasKit
#
# Created by quinn on 2019-01-14.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 工具入口
  #
  class Entry
    # 执行入口
    #
    # @param argv [Array] 命令行参数数组
    #
    def self.start(argv)
      Command.load.run(argv)
    rescue CommandError => e
      UILogger.exception(e)
      UILogger.console ''
      UILogger.console e.error_cmd.usage
      exit(10)
    rescue StandardError => e
      UILogger.exception(e)
      raise
    end
  end
end
