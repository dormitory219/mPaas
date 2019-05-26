# frozen_string_literal: true

# build_setting.rb
# MpaasKit
#
# Created by quinn on 2019-01-09.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # xcode工程 build setting 相关操作
  #
  class XcodeHelper
    # build settings 名称
    BS_INFO_PLIST = 'INFOPLIST_FILE'                          # plist 路径
    BS_PREFIX_HEADER = 'GCC_PREFIX_HEADER'                    # pch 路径
    BS_PREFIX_HEADER_COMPILE = 'GCC_PRECOMPILE_PREFIX_HEADER' # 是否启用 pch 预编译
    BS_FRAMEWORK_SEARCH_PATHS = 'FRAMEWORK_SEARCH_PATHS'      # framework 搜索路径
    BS_BUNDLE_ID = 'PRODUCT_BUNDLE_IDENTIFIER'                # bundle id
    BS_LD_FLAGS = 'OTHER_LDFLAGS'                             # link 标记
    BS_WARNING_FLAGS = 'WARNING_CFLAGS'                       # 警告标记
    BS_MACHO_TYPE = 'MACH_O_TYPE'                             # mach-o type

    BS_VAR_SRCROOT = '$(SRCROOT)'                             # src root 变量
    BS_VAR_PROJECT_NAME = '$(PROJECT_NAME)'                   # project name 变量

    class << self
      # 查找 info.plist 文件
      #
      # @param project_path 工程路径
      # @param target_name target 名称
      # @return [Pathname] info.list 文件路径（绝对路径）
      #
      def search_info_plist_path(project_path, target_name)
        path = search_build_setting_field(project_path, target_name, BS_INFO_PLIST)
        src_root = read_xcode_build_vars(project_path, target_name, 'SRCROOT')
        path = Pathname.new(path.gsub(/#{Regexp.quote(BS_VAR_SRCROOT)}/, src_root))
        path.relative? ? project_path.parent + path : path
      end

      # 查找 .pch 文件
      #
      # @param project_path 工程路径
      # @param target_name target 名称
      # @return [Pathname] .pch 文件路径
      #         如果路径不存在，返回 pch 文件所在目录的路径
      #
      def search_pch_path(project_path, target_name)
        # 未设置 pch 则返回和 info.plist 同一目录
        info_plist_dir = search_info_plist_path(project_path, target_name).parent
        path = search_build_setting_field(project_path, target_name, BS_PREFIX_HEADER)
        return info_plist_dir if path.nil?
        # 替换路径中的变量
        src_root = read_xcode_build_vars(project_path, target_name, 'SRCROOT')
        project_name = read_xcode_build_vars(project_path, target_name, 'PROJECT_NAME')
        path = Pathname.new(path.gsub(/#{Regexp.quote(BS_VAR_SRCROOT)}|#{Regexp.quote(BS_VAR_PROJECT_NAME)}/,
                                      BS_VAR_SRCROOT => src_root,
                                      BS_VAR_PROJECT_NAME => project_name))
        path.relative? ? project_path.parent + path : path
      end

      # 更新 pch build setting
      #
      # @param project_path 工程路径
      # @param target_name target 名称
      # @param pch_path pch 文件的相对路径
      #
      def update_pch_build_setting(project_path, target_name, pch_path)
        src_root = Pathname.new(project_path).parent
        values_by_field = {
          BS_PREFIX_HEADER_COMPILE => 'YES',
          BS_PREFIX_HEADER => Pathname.new(pch_path).relative_path_from(src_root)
        }
        update_build_setting_fields(project_path, target_name, values_by_field)
      end

      # 查找工程某项 build setting 字段值
      #
      # @param project_path 工程路径
      # @param target_name target 名称
      # @param field 字段名
      # @return [String] 字段值
      #
      def search_build_setting_field(project_path, target_name, field)
        native_target = find_native_target(project_path, target_name)
        native_target.resolved_build_setting(field).values.compact.uniq.first unless native_target.nil?
      end

      # 更新 build setting 的值
      #
      # @param project_path 工程路径
      # @param target_name target 名称
      # @param override_values [Hash] 字段更新的值，已有字段直接覆盖值
      # @param append_values [Hash] 字段追加的值，已有字段后面追加新值
      # @param remove_values [Hash] 字段删除的值，已有字段中删除
      #
      def update_build_setting_fields(project_path, target_name,
                                      override_values, append_values = {}, remove_values = {})
        override_values ||= {}
        append_values ||= {}
        remove_values ||= {}
        UILogger.debug "覆盖 build settings: #{override_values}" unless override_values.empty?
        UILogger.debug "更新 build settings: #{append_values}" unless append_values.empty?
        UILogger.debug "删除 build settings: #{remove_values}" unless remove_values.empty?
        project_write(project_path) do |_|
          native_target = find_native_target(project_path, target_name)
          native_target.build_configurations.each do |c|
            update_hash!(c.build_settings, override_values, append_values, remove_values)
          end
        end
      end

      private

      # 更新字典
      #
      # @param [Hash] modified_hash 待修改的字典，返回后将被修改
      # @param [Hash] merge_key_values 合并的内容字典
      # @param [Hash] append_key_values 追加的内容字典
      # @param [Hash] remove_key_values 支持移除数组类的 setting
      #
      def update_hash!(modified_hash, merge_key_values, append_key_values, remove_key_values)
        merge_key_values ||= {}
        # 先删除
        remove_key_values.each { |k, v| modified_hash[k] = Array(modified_hash[k]) - Array(v) }
        # 更新
        modified_hash.merge!(merge_key_values)
        # 追加
        append_key_values.each { |k, v| modified_hash[k] = (Array(modified_hash[k]) + Array(v)).uniq }
      end
    end
  end
end
