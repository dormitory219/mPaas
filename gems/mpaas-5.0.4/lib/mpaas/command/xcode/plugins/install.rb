# frozen_string_literal: true

# install.rb
# MpaasKit
#
# Created by quinn on 2019-03-03.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class Command
    class Xcode
      class Plugins
        # Xcode 插件安装
        #
        class Install < Plugins
          include Config::Mixin

          def summary
            '安装 Xcode 插件'
          end

          def define_parser(parser)
            parser.description = summary
            parser.add_argument('--local=PATH',
                                :desc => '从本地安装包进行安装') { |opt| @local_path = opt }
            parser.add_argument('-V=VERSION',
                                :desc => '安装指定版本的 Xcode 插件') { |opt| @install_version = opt }
            parser.add_argument('--latest',
                                :default => -> { false },
                                :desc => '安装最新版本的 Xcode 插件 \
                                         !!慎用，最新版有可能和当前 mPaaS 工具不兼容导致功能失效') { |opt| @latest = opt }
          end

          def run(argv)
            super(argv)
            if XCPlugin::Installer.installed?
              UILogger.info('已安装 Xcode 插件')
            elsif perform_install
              # 安装成功之后，刷新 uuid，去 Xcode 签名
              XCPlugin::PluginManager.refresh_plugins_uuid
              XCPlugin::PluginManager.unsign_xcode
            end
          end

          private

          # 安装
          #
          # @return [Bool]
          #
          def perform_install
            if !@local_path.nil? # 从本地包进行安装
              XCPlugin::Installer.install_from_local(@local_path)
            elsif !@install_version.nil? # 直接安装指定版本
              XCPlugin::Installer.update(@install_version)
            elsif @latest # 安装最新版本
              XCPlugin::Installer.update_latest
            else # 安装和当前工具版本匹配的最新版本，版本号高才可以升级
              XCPlugin::Installer.install(config.version)
            end
          end
        end
      end
    end
  end
end
