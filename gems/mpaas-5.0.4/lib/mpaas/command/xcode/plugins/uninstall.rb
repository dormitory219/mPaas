# frozen_string_literal: true

# uninstall.rb
# MpaasKit
#
# Created by quinn on 2019-03-03.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class Command
    class Xcode
      class Plugins
        # 卸载 Xcode 插件
        #
        class Uninstall < Plugins
          def summary
            '卸载 Xcode 插件'
          end

          def define_parser(parser)
            parser.description = summary
          end

          def run(argv)
            super(argv)
            UILogger.info('您尚未安装 Xcode 插件') unless XCPlugin::Installer.installed?
            XCPlugin::Installer.uninstall
          end
        end
      end
    end
  end
end
