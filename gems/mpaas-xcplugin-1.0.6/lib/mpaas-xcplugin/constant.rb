# frozen_string_literal: true

# constant.rb
# MpaasKit
#
# Created by quinn on 2019-01-16.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  module XCPlugin
    # 常量
    #
    class Constant
      # xcode 插件文件名称
      XCODE_PLUGIN_NAME = 'mPaaSPlugin.xcplugin'
      # 配置文件名称
      MANIFEST_NAME = 'manifest.json'

      class << self
        # 系统 xcode 插件的加载目录
        #
        # @return [Pathname]
        #
        def xcode_plugin_dir
          Pathname.new(ENV['HOME'] + '/Library/Application Support/Developer/Shared/Xcode/Plug-ins')
        end

        # xcode 插件文件名称
        #
        # @return [String]
        #
        def xcode_plugin_name
          XCODE_PLUGIN_NAME
        end

        # 配置文件名称
        #
        # @return [String]
        #
        def manifest_name
          MANIFEST_NAME
        end

        # 配置文件下载地址
        #
        # @return [String]
        #
        def manifest_uri
          MpaasEnv.xcode_plugin_home_uri + '/' + MANIFEST_NAME
        end
      end
    end
  end
end
