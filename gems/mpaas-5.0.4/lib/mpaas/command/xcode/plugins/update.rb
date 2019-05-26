# frozen_string_literal: true

# update.rb
# MpaasKit
#
# Created by quinn on 2019-01-16.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class Command
    class Xcode
      class Plugins
        # 更新 Xcode 插件
        #
        class Update < Plugins
          include Config::Mixin

          def summary
            '更新 mPaaS 的 Xcode 插件'
          end

          def define_parser(parser)
            parser.description = summary
            parser.add_argument('-V VERSION',
                                :desc => '更新对应版本的 Xcode 插件') { |opt| @update_version = opt }
            parser.add_argument('--latest',
                                :default => -> { false },
                                :desc => '更新最新版本的 Xcode 插件' \
                                         '!!慎用，最新版有可能和当前 mPaaS 工具不兼容导致功能失效') { |opt| @latest = opt }
            parser.add_argument('--local=PATH',
                                :desc => '从本地安装包进行安装') { |opt| @local_path = opt }
          end

          def run(argv)
            super(argv)
            return unless perform_update
            # 更新成功，执行去签名，刷新 uuid
            XCPlugin::PluginManager.refresh_plugins_uuid
            XCPlugin::PluginManager.unsign_xcode
          end

          private

          # 执行更新
          #
          # @return [Bool]
          #
          def perform_update
            if @local_path
              XCPlugin::Installer.install_from_local(@local_path)
            elsif @latest
              XCPlugin::Installer.update_latest
            elsif @update_version
              XCPlugin::Installer.update(@update_version)
            else
              # 普通更新，版本号高才可以升级
              XCPlugin::Installer.check_for_updates(config.version)
            end
          end
        end
      end
    end
  end
end
