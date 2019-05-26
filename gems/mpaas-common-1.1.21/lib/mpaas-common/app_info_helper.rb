# frozen_string_literal: true

# app_info_helper.rb
# MpaasKit
#
# Created by quinn on 2019-03-03.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 应用信息工具
  #
  class AppInfoHelper
    # 应用信息
    #
    class AppInfo
      def initialize(config_file)
        return unless File.exist?(config_file)
        # 解析数据
        app_info = JSON.parse(File.read(config_file))
        @app_id = app_info[Constants::CONFIG_APP_ID_KEY]
        @workspace_id = app_info[Constants::CONFIG_WORKSPACE_ID_KEY]
        @bundle_id = app_info[Constants::CONFIG_BUNDLE_ID_KEY]
        @app_key = app_info[Constants::CONFIG_APP_KEY_KEY]
        @log_gw = app_info[Constants::CONFIG_LOG_GW_KEY]
        @rpc_gw = app_info[Constants::CONFIG_RPC_GW_KEY]
        @mpaas_api = app_info[Constants::CONFIG_MPAAS_API_KEY]
        @sync_server = app_info[Constants::CONFIG_SYNC_SERVER_KEY]
        @sync_port = app_info[Constants::CONFIG_SYNC_PORT_KEY]
      end

      attr_reader :app_id, :workspace_id, :app_key, :bundle_id,
                  :log_gw, :rpc_gw, :mpaas_api, :sync_port, :sync_server
    end

    class << self
      # 从配置文件中解析信息
      #
      # @param [String] config_file 配置文件
      # @return [AppInfo]
      #
      def app_info_from_config(config_file)
        AppInfo.new(config_file)
      end
    end
  end
end
