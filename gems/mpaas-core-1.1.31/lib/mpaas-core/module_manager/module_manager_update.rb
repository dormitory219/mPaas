# frozen_string_literal: true

# module_manager_update.rb
# MpaasKit
#
# Created by quinn on 2019-03-11.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 模块管理，升级部分
  #
  class ModuleManager
    # 检查模块升级信息
    # （只查看相同基线下的升级信息）
    #
    # @return [Hash] 模块升级信息
    #
    def check_update_info
      # 校验基线版本
      validate_update_baseline
      # 当前所有模块的版本信息
      versions_info = @resolver.resolve_module_versions_info(@project.active_target)
      # 兼容 v4 结构
      names = if basic_info.active_v4
                versions_info.keys.map { |name| [name, @baseline_manager.version] }
              else
                versions_info = versions_info.map { |k, v| [ModuleConfig.module_name(k), v] }.to_h
                versions_info.keys
              end
      # 最新模块列表
      latest_modules = @baseline_manager.fetch_module_info(names)
      UpdateInfo.parse(versions_info, latest_modules)
    end

    private

    # 提取需要更新的模块
    #
    # @param [Array] modules 更新的模块数组，只支持最新版本
    #        e.g. [name1, name2, ....]
    # @return [Array<String>] 确实需要更新的模块数组
    # TODO: 暂时只支持更新到最新版本
    #
    def extract_update_modules(modules)
      update_info = check_update_info
      # 无更新信息，返回空
      return [] if update_info.nil?
      # 选出确实有更新的模块
      modules.map { |entry| entry.is_a?(Array) ? entry.first : entry }.map do |module_name|
        need_update = update_info.fetch(module_name, {}).fetch(:available, false)
        UILogger.warning("指定的模块 #{module_name} 不需要更新") unless need_update
        need_update ? module_name : nil
      end.compact
    end
  end
end
