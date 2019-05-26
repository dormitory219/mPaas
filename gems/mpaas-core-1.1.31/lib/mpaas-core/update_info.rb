# frozen_string_literal: true

# update_info.rb
# MpaasKit
#
# Created by quinn on 2019-02-21.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 模块更新信息
  #
  class UpdateInfo
    class << self
      # 解析
      #
      # @param [Hash] versions_info 工程模块版本信息
      # @param [Array<ModuleObject>] module_obj_list 最新模块列表
      # @return [Hash] 模块更新信息
      #         e.g. { "mPaaS_Push": {"available": true, "version": "1.0.1"}, ... }
      #              { "mPaaS_Push": {"available": true, "versions": { "APPushSDK": "1.0.1" } }, ... }
      #
      def parse(versions_info, module_obj_list)
        update_info = {}
        versions_info.each do |module_name, value|
          # 找到模块
          module_obj = module_obj_list.find { |m| m.name == module_name }
          # 模块不存在 或 非 component 模块不添加
          next if module_obj.nil? || !module_obj.component?
          # 组装信息
          available = false
          if value.is_a?(String) # 兼容 v4
            available = check_update_available_old(module_obj, versions_info)
          elsif value.is_a?(Hash)
            available = check_update_available(module_obj, value)
          end
          version = available ? module_obj.version : ''
          update_info[module_name] = { :available => available, :version => version }
        end
        update_info
      end

      private

      # 检查某个模块是否可升级
      #
      # @param [ModuleObject] module_obj 模块对象
      # @param [Hash] existing_versions 所有的模块版本信息
      # @return [Bool]
      #
      def check_update_available_old(module_obj, existing_versions)
        same_version = VersionCompare.compare(module_obj.version).equal_to?(existing_versions[module_obj.name])
        dependency_modules = module_obj.find_dependency_module([module_obj])
        # 模块版本号相同并且依赖也相同，不需要升级
        !same_version || dependency_modules.reject do |m|
          # 依赖的是component直接去除，模块包含，并且版本号相同，不需要升级
          m.component? ||
            (existing_versions.key?(m.name) && VersionCompare.compare(m.version).equal_to?(existing_versions[m.name]))
        end.count.positive?
      end

      # 检查某个模块是否可升级
      #
      # @param [ModuleObject] module_obj 模块对象
      # @param [Hash] existing_frameworks 所有的模块工程包版本信息
      # @return [Bool]
      #
      def check_update_available(module_obj, existing_frameworks)
        versions_info = module_obj.frameworks_version_info
        same_framework_versions = true
        existing_frameworks.each do |framework, version|
          same_framework_versions = versions_info.key?(framework) &&
                                    VersionCompare.compare(versions_info[framework]).equal_to?(version)
          break unless same_framework_versions
        end
        # 模块相同，并且版本相同，不需要升级
        !(versions_info.keys.sort == existing_frameworks.keys.sort && same_framework_versions)
      end
    end
  end
end
