# frozen_string_literal: true

# config_data_controller.rb
# MpaasKit
#
# Created by quinn on 2019-02-13.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class MpaasFramework
    # 云端配置数据控制器
    # 包括 Info.plist 和 category 文件内的配置
    #
    class ConfigDataController
      include BasicInfo::Mixin

      def initialize(project)
        @project = project
        @plist_injector = InfoPlistInjector.new
      end

      # 加载原始的云端数据
      #
      # @param [String] config_data_file 云端数据配置文件
      #
      def load_origin_data(config_data_file)
        @origin_data = JSON.parse(File.read(config_data_file)) if File.exist?(config_data_file)
      end

      # 导入新数据
      #
      # @param [String] target_node_path
      #
      def import_data(target_node_path)
        # 空框架工程直接注入 mpaas 信息
        if @origin_data.nil?
          @plist_injector.inject_mpaas_info(@project.xcodeproj_path, @project.active_target)
          return
        end
        # 更新 Info.plist 内容
        @plist_injector.update_mpaas_info(@project.xcodeproj_path, @project.active_target)
        # 按顺序替换分类文件内容
        UILogger.debug('替换分类文件中的环境配置')
        current_data = basic_info.app_info
        [Constants::CONFIG_APP_KEY_KEY, Constants::CONFIG_APP_ID_KEY, Constants::CONFIG_WORKSPACE_ID_KEY,
         Constants::CONFIG_RPC_GW_KEY, Constants::CONFIG_LOG_GW_KEY, Constants::CONFIG_SYNC_SERVER_KEY,
         Constants::CONFIG_SYNC_PORT_KEY].each do |key|
          # 替换所有 .m 文件
          FileProcessor.global_replace_file_content!({ @origin_data[key] => current_data[key] },
                                                     target_node_path.to_s + '/**/*.m')
        end
      end

      # 将配置信息注入到 Info.plist 中
      #
      # @param [String] target
      #
      def inject_mpaas_info(target)
        @plist_injector.inject_mpaas_info(@project.xcodeproj_path, target) if target == @project.active_target
      end

      # 移除 Info.plist 内部配置信息
      #
      # @param [String] target
      #
      def remove_mpaas_info(target)
        @plist_injector.remove_mpaas_info(@project.xcodeproj_path, target)
      end
    end
  end
end
