# frozen_string_literal: true

# version.rb
# MpaasKit
#
# Created by quinn on 2019-01-16.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class Command
    class Xcode
      class Plugins
        # Xcode 插件版本
        #
        class Version < Plugins
          def summary
            'mPaaS 的 Xcode 插件版本'
          end

          def define_parser(parser)
            parser.description = summary
          end

          def run(argv)
            super(argv)
            UILogger.info(XCPlugin::Installer.version)
          end
        end
      end
    end
  end
end
