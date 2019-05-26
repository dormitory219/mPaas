# frozen_string_literal: true

# sdk.rb
# MpaasKit
#
# Created by quinn on 2019-01-16.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class Command
    # sdk 命令
    #
    class Sdk < Command
      def summary
        'mPaaS SDK 相关命令集'
      end

      def define_parser(parser)
        parser.description = summary
      end
    end
  end
end
