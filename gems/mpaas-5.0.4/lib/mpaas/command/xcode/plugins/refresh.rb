# frozen_string_literal: true

# refresh.rb
# MpaasKit
#
# Created by quinn on 2019-01-17.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class Command
    class Xcode
      class Plugins
        # 刷新 Xcode 插件的 uuid
        #
        class Refresh < Plugins
          def summary
            '刷新 mPaaS 的 Xcode 插件的 uuid'
          end

          def define_parser(parser)
            parser.description = summary
          end

          def run(argv)
            super(argv)
            XCPlugin::PluginManager.refresh_plugins_uuid
          end
        end
      end
    end
  end
end
