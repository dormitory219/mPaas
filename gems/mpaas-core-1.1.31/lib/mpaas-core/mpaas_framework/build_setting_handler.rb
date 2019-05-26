# frozen_string_literal: true

# build_setting_handler.rb
# MpaasKit
#
# Created by quinn on 2019-01-15.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class MpaasFramework
    # 处理工程中的 build settings 项
    #
    class BuildSettingHandler
      include BasicInfo::Mixin

      def initialize(project)
        @project = project
      end

      # 处理 build settings
      #
      # @param root [MpaasNode] 框架根节点，用来提取一些默认值
      # @param target_name [String] target 名称
      # @param target_info [MpaasTargetInfo] target 信息
      #
      def handle_build_settings(root, target_name, target_info)
        UILogger.info "处理 build settings 参数: #{target_name}"
        override_settings = {}
        append_settings = {}
        remove_settings = {}
        xcodeproj_path = @project.xcodeproj_path
        # 用全部的 build settings 来更新
        all_build_settings = [
          framework_search_paths(root, target_info, target_name), # framework search path
          pch_build_settings(root, xcodeproj_path, target_name),  # pch
          bundle_id_build_settings(target_name),                  # bundle id
          ld_flag_build_settings,                                 # link flags
          warning_flag_build_settings                             # warning flags
        ]
        all_build_settings.each do |override, append, remove|
          override_settings.update(override) unless override.nil?
          append_settings.update(append) unless append.nil?
          remove_settings.update(remove) unless remove.nil?
        end
        XcodeHelper.update_build_setting_fields(xcodeproj_path, target_name,
                                                override_settings, append_settings, remove_settings)
      end

      # 删除 build settings
      # 目前只移除 framework search paths
      #
      # @param [MpaasNode] root
      # @param [String] target_name
      # @param [MpaasTargetInfo] _target_info
      #
      def remove_build_settings(root, target_name, _target_info)
        UILogger.info('移除相关 build settings')
        xcodeproj_path = @project.xcodeproj_path
        copy_path = root.find(Constants::FRAMEWORKS_GROUP_KEY).path
        remove_settings = {
          XcodeHelper::BS_FRAMEWORK_SEARCH_PATHS => existing_framework_search_path(copy_path, target_name)
        }
        XcodeHelper.update_build_setting_fields(xcodeproj_path, target_name,
                                                nil, nil, remove_settings)
      end

      private

      # framework search paths build setting
      #
      # @param root [MpaasNode] 框架根节点，用来提取一些默认值
      # @param target_info [MpaasTargetInfo] target 信息
      # @param [String] target_name
      # @return [Array<Hash>] 返回相应的 build setting 项
      #         包括3个元素，第一个为覆盖的项，第二个为追加的项，第三个为移除的项
      # e.g. [nil, { 'SETTING_KEY' => 'xxxx' }, nil]
      #
      def framework_search_paths(root, target_info, target_name)
        copy_path = '$(PROJECT_DIR)/' + root.find(Constants::FRAMEWORKS_GROUP_KEY).path
        update_paths, remove_paths = extract_modify_paths(target_info, copy_path, target_name)
        append_settings = { XcodeHelper::BS_FRAMEWORK_SEARCH_PATHS => update_paths }
        remove_settings = remove_paths.empty? ? nil : { XcodeHelper::BS_FRAMEWORK_SEARCH_PATHS => remove_paths }
        [nil, append_settings, remove_settings]
      end

      # 工程配置中已经存在的 framework search path
      #
      # @param [String] copy_path
      # @param [String] target_name
      # @return [Array]
      #
      def existing_framework_search_path(copy_path, target_name)
        existing_paths = XcodeHelper.search_build_setting_field(@project.xcodeproj_path, target_name,
                                                                XcodeHelper::BS_FRAMEWORK_SEARCH_PATHS)
        Array(existing_paths).select do |p|
          p == copy_path || p.start_with?(LocalPath.sdk_home_dir.to_s)
        end
      end

      # 提取每个修改的 path
      #
      # @param [MpaasTargetInfo] target_info
      # @param [String] copy_path copy 模式的 search path
      # @param [String] target_name
      # @return [Array<Array>] 更新的路径和移除的路径数组
      #
      def extract_modify_paths(target_info, copy_path, target_name)
        update_paths = [Constants::INHERITED]
        # 先移除旧的路径，所有 sdk 目录下的路径全移除
        remove_paths = existing_framework_search_path(copy_path, target_name)
        # 再根据 copy 模式添加新的
        if basic_info.copy_mode
          update_paths << copy_path
        else
          target_info.mpaas_frameworks.each do |_, location, op|
            path = File.dirname(location) + '/**'
            op == :del ? remove_paths << path : update_paths << path
          end
        end
        [update_paths.uniq.compact, remove_paths.uniq.compact]
      end

      # pch build setting
      #
      # @param root [MpaasNode] 框架根节点，用来提取一些默认值
      # @param xcodeproj_path [Pathname] 工程文件路径
      # @param target_name [String] target 名称
      # @return [Array<Hash>] 返回相应的 build setting 项
      #         包括3个元素，第一个为覆盖的项，第二个为追加的项，第三个为移除的项
      # e.g. [nil, { 'SETTING_KEY' => 'xxxx' }, nil]
      #
      def pch_build_settings(root, xcodeproj_path, target_name)
        pch_path = XcodeHelper.search_pch_path(xcodeproj_path, target_name)
        override_settings = nil
        # 存在 pch 文件就不再更新配置
        if pch_path.directory?
          pch_path += root.find('.pch').name
          override_settings = {
            XcodeHelper::BS_PREFIX_HEADER_COMPILE => 'YES',
            XcodeHelper::BS_PREFIX_HEADER => pch_path.relative_path_from(xcodeproj_path.parent).to_s
          }
        end
        [override_settings, nil, nil]
      end

      # bundle id build setting
      #
      # @return [Array<Hash>] 返回相应的 build setting 项
      #         包括3个元素，第一个为覆盖的项，第二个为追加的项，第三个为移除的项
      # e.g. [nil, { 'SETTING_KEY' => 'xxxx' }, nil]
      #
      def bundle_id_build_settings(target_name)
        override_settings = { XcodeHelper::BS_BUNDLE_ID => basic_info.app_info[Constants::CONFIG_BUNDLE_ID_KEY] }
        override_settings = nil if target_name != @project.active_target
        [override_settings, nil, nil]
      end

      # ld flags build setting
      #
      # @return [Array<Hash>] 返回相应的 build setting 项
      #         包括3个元素，第一个为覆盖的项，第二个为追加的项，第三个为移除的项
      # e.g. [nil, { 'SETTING_KEY' => 'xxxx' }, nil]
      #
      def ld_flag_build_settings
        append_settings = {
          XcodeHelper::BS_LD_FLAGS => %W[#{Constants::INHERITED} -ObjC -lz -lsqlite3 -lxml2 -lc++ -lbz2]
        }
        [nil, append_settings, nil]
      end

      # warning flags build setting
      #
      # @return [Array<Hash>] 返回相应的 build setting 项
      #         包括3个元素，第一个为覆盖的项，第二个为追加的项，第三个为移除的项
      # e.g. [nil, { 'SETTING_KEY' => 'xxxx' }, nil]
      #
      def warning_flag_build_settings
        append_settings = { XcodeHelper::BS_WARNING_FLAGS => '-Wno-objc-protocol-method-implementation' }
        [nil, append_settings, nil]
      end
    end
  end
end
