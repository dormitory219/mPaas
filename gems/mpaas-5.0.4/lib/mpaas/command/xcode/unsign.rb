# frozen_string_literal: true

# unsign.rb
# MpaasKit
#
# Created by quinn on 2019-01-16.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class Command
    class Xcode
      # 去除 Xcode 签名
      #
      class Unsign < Xcode
        def summary
          '去除 Xcode 签名'
        end

        def define_parser(parser)
          parser.description = summary
        end

        def run(argv)
          super(argv)
          XCPlugin::PluginManager.unsign_xcode
        end
      end
    end
  end
end
