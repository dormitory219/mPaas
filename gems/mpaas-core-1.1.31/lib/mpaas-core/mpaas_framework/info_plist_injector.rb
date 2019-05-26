# frozen_string_literal: true

# info_plist_injector.rb
# MpaasKit
#
# Created by quinn on 2019-01-14.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class MpaasFramework
    # 注入 info.plist
    #
    class InfoPlistInjector
      include BasicInfo::Mixin

      # 注入 mpaas 信息
      #
      # @param xcodeproj_path [Pathname] 工程文件路径
      # @param target [String] 对应的 target 名称
      #
      def inject_mpaas_info(xcodeproj_path, target)
        UILogger.info "向 Info.plist 内注入 mPaaS 信息: #{target}"
        plist_path = XcodeHelper.search_info_plist_path(xcodeproj_path, target)
        inject_product_id(plist_path) if basic_info.active_v4
        inject_product_version(plist_path)
        inject_mpaas(plist_path) if basic_info.active_v4
        inject_mpaas_internal(plist_path) if basic_info.active_v4
      end

      # 更新 mpaas 信息
      #
      # @param xcodeproj_path [Pathname] 工程文件路径
      # @param target [String] 对应的 target 名称
      #
      def update_mpaas_info(xcodeproj_path, target)
        return unless basic_info.active_v4
        # 兼容 v4
        UILogger.info "更新 Info.plist 内 mPaaS 信息: #{target}"
        plist_path = XcodeHelper.search_info_plist_path(xcodeproj_path, target)
        update_product_id(plist_path)
        update_mpaas(plist_path)
        update_mpaas_internal(plist_path)
      end

      # 移除 mpaas 信息
      #
      # @param [pathname] xcodeproj_path
      # @param [String] target
      #
      def remove_mpaas_info(xcodeproj_path, target)
        UILogger.info("删除 Info.plist 内 mPaaS 信息: #{target}")
        plist_path = XcodeHelper.search_info_plist_path(xcodeproj_path, target)
        remove_product_id(plist_path)
        remove_mpaas(plist_path)
        remove_mpaas_internal(plist_path)
      end

      private

      PRODUCT_ID_KEY = 'Product ID'
      PRODUCT_VERSION_KEY = 'Product Version'
      MPAAS_KEY = 'mPaaS'
      MPAAS_INTERNAL_KEY = 'mPaaSInternal'

      # 注入 product id
      #
      # @param plist_path [String] plist 文件地址
      #
      def inject_product_id(plist_path)
        return if PlistAccessor.entry_exists?(plist_path, [PRODUCT_ID_KEY])
        # 不存在就添加
        UILogger.debug("设置 Product ID: #{current_product_id}")
        PlistAccessor.add_entry!(plist_path, [PRODUCT_ID_KEY], current_product_id)
      end

      # 注入 product version
      #
      # @param plist_path [String] plist 文件地址
      #
      def inject_product_version(plist_path)
        return if PlistAccessor.entry_exists?(plist_path, [PRODUCT_VERSION_KEY])
        # 不存在就添加
        product_version = '1.0.0.0'
        UILogger.debug("设置 Product Version: #{product_version}")
        PlistAccessor.add_entry!(plist_path, [PRODUCT_VERSION_KEY], product_version)
      end

      # 注入 mPaaS
      #
      # @param plist_path [String] plist 文件地址
      #
      def inject_mpaas(plist_path)
        return if PlistAccessor.entry_exists?(plist_path, [MPAAS_KEY])
        # 不存在就添加
        UILogger.debug("设置 mPaaS: #{current_default_mpaas}")
        PlistAccessor.add_entry!(plist_path, [MPAAS_KEY], current_default_mpaas)
      end

      # 注入 mPaaSInternal
      #
      # @param plist_path [String] plist 文件地址
      #
      def inject_mpaas_internal(plist_path)
        return if PlistAccessor.entry_exists?(plist_path, [MPAAS_INTERNAL_KEY])
        # 不存在就添加
        UILogger.debug("设置 mPaaSInternal: #{current_default_mpaas_internal}")
        PlistAccessor.add_entry!(plist_path, [MPAAS_INTERNAL_KEY], current_default_mpaas_internal)
      end

      # 更新 product id
      #
      # @param plist_path [String] plist 文件地址
      #
      def update_product_id(plist_path)
        UILogger.debug("设置 Product ID: #{current_product_id}")
        PlistAccessor.update_entry!(plist_path, [PRODUCT_ID_KEY], current_product_id)
      end

      # 更新 mPaaS
      #
      # @param plist_path [String] plist 文件地址
      #
      def update_mpaas(plist_path)
        mpaas = if PlistAccessor.entry_exists?(plist_path, [MPAAS_KEY])
                  # 取已经存在的值
                  PlistAccessor.fetch_entry(plist_path, [MPAAS_KEY])
                else
                  {}
                end
        return if mpaas == current_default_mpaas
        # 存在节点并且不同，直接更新
        mpaas = mpaas.update(current_default_mpaas)
        UILogger.debug("设置 mPaaS: #{mpaas}")
        PlistAccessor.update_entry!(plist_path, [MPAAS_KEY], mpaas)
      end

      # 更新 mPaaSInternal
      #
      # @param plist_path [String] plist 文件地址
      #
      def update_mpaas_internal(plist_path)
        mpaas_internal = if PlistAccessor.entry_exists?(plist_path, [MPAAS_INTERNAL_KEY])
                           # 取已经存在的值
                           PlistAccessor.fetch_entry(plist_path, [MPAAS_INTERNAL_KEY])
                         else
                           {}
                         end
        return if mpaas_internal == current_default_mpaas_internal
        # 存在节点并且不同，直接更新
        mpaas_internal = mpaas_internal.update(current_default_mpaas_internal)
        UILogger.debug("设置 mPaaSInternal: #{mpaas_internal}")
        PlistAccessor.update_entry!(plist_path, [MPAAS_INTERNAL_KEY], mpaas_internal)
      end

      # 移除 product id
      #
      # @param plist_path [String] plist 文件地址
      #
      def remove_product_id(plist_path)
        return unless PlistAccessor.entry_exists?(plist_path, [PRODUCT_ID_KEY])
        # 移除 product id
        PlistAccessor.remove_entry!(plist_path, [PRODUCT_ID_KEY])
      end

      # 移除 mPaaS
      #
      # @param plist_path [String] plist 文件地址
      #
      def remove_mpaas(plist_path)
        return unless PlistAccessor.entry_exists?(plist_path, [MPAAS_KEY])
        # 移除 mPaaS
        PlistAccessor.remove_entry!(plist_path, [MPAAS_KEY])
      end

      # 移除 mPaaSInternal
      #
      # @param plist_path [String] plist 文件地址
      #
      def remove_mpaas_internal(plist_path)
        return unless PlistAccessor.entry_exists?(plist_path, [MPAAS_INTERNAL_KEY])
        # 移除 mPaaSInternal
        PlistAccessor.remove_entry!(plist_path, [MPAAS_INTERNAL_KEY])
      end

      # 当前环境的 product id
      #
      # @return [String]
      #
      def current_product_id
        app_key = basic_info.app_info[Constants::CONFIG_APP_KEY_KEY]
        workspace_id = basic_info.app_info[Constants::CONFIG_WORKSPACE_ID_KEY]
        app_key + '-' + workspace_id
      end

      # 当前环境的 mpaas
      #
      # @return [Hash]
      #
      def current_default_mpaas
        {
          :WorkspaceId => basic_info.app_info[Constants::CONFIG_WORKSPACE_ID_KEY],
          :AppId => basic_info.app_info[Constants::CONFIG_APP_ID_KEY],
          :UniformGateway => basic_info.app_info[Constants::CONFIG_MPAAS_API_KEY],
          :Platform => 'IOS'
        }
      end

      # 当前环境的 mpaas internal
      #
      # @return [Hash]
      #
      def current_default_mpaas_internal
        {
          :SyncPort => basic_info.app_info[Constants::CONFIG_SYNC_PORT_KEY],
          :SyncServer => basic_info.app_info[Constants::CONFIG_SYNC_SERVER_KEY]
        }
      end
    end
  end
end
