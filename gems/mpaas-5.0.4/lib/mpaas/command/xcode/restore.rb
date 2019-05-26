# frozen_string_literal: true

# restore.rb
# MpaasKit
#
# Created by quinn on 2019-01-16.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class Command
    class Xcode
      # 恢复 Xcode 的签名
      #
      class Restore < Xcode
        def summary
          '恢复 Xcode 签名'
        end

        def define_parser(parser)
          parser.description = summary
        end

        def run(argv)
          super(argv)
          XCPlugin::PluginManager.restore_xcode
        end
      end
    end
  end
end
