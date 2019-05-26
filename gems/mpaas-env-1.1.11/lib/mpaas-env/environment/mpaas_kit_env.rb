# frozen_string_literal: true

# mpaas_kit_env.rb
# MpaasKit
#
# Created by quinn on 2019-01-19.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # mpaas 环境，命令行工具相关环境
  #
  class MpaasEnv
    class << self
      # mpaas 命令行工具地址
      #
      # @return [String]
      #
      def mpaas_kit_home_uri
        mpaas_base_uri + env_info['MPAAS_KIT']['Home']
      end

      # 命令行工具安装包地址
      #
      # @return [String]
      #
      def mpaas_kit_package_uri
        mpaas_kit_home_uri + env_info['MPAAS_KIT']['Package']
      end

      # xcode 插件的根目录地址
      #
      # @return [String]
      #
      def xcode_plugin_home_uri
        mpaas_kit_home_uri + env_info['MPAAS_KIT']['XCODE_PLUGIN']['Home']
      end

      # xcode 插件的仓库地址
      #
      # @return [String]
      #
      def xcode_plugin_repo_uri
        xcode_plugin_home_uri + env_info['MPAAS_KIT']['XCODE_PLUGIN']['Repo']
      end

      # 最新版 xcode 插件地址
      #
      # @return [String]
      #
      def xcode_plugin_latest_uri
        xcode_plugin_repo_uri + env_info['MPAAS_KIT']['XCODE_PLUGIN']['Latest']
      end
    end
  end
end
