# frozen_string_literal: true

# xcode.rb
# MpaasKit
#
# Created by quinn on 2019-01-16.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class Command
    # xcode 相关命令
    #
    class Xcode < Command
      require 'reuse_xcode_plugins'

      def summary
        'xcode 相关命令'
      end

      def define_parser(parser)
        parser.description = summary
      end
    end
  end
end
