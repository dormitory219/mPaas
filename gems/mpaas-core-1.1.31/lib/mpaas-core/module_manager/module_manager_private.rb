# frozen_string_literal: true

# module_manager_private.rb
# workspace
#
# Created by quinn on 2019-03-25.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 模块管理，私有方法部分
  #
  class ModuleManager
    private

    # 添加模块的操作
    #
    # @param [Array] modules 添加的模块
    # @param [MpaasFramework] framework 框架
    # @param [String] baseline 基线版本
    #
    def add_module_to_framework(modules, framework, baseline)
      return if modules.empty?
      # 添加的模块对象列表
      add_module_obj_list = @baseline_manager.fetch_module_info(modules, baseline)
      framework.update(add_module_obj_list, :add, baseline)
      framework.integrate!
    end

    # 移除模块的操作
    #
    # @param [Array] modules 移除的模块
    # @param [MpaasFramework] framework 框架
    # @param [String] baseline 基线版本
    #
    def remove_module_from_framework(modules, framework, baseline)
      return if modules.empty?
      # 删除的模块对象列表
      del_module_obj_list = @baseline_manager.fetch_module_info_ref(modules, baseline)
      del_module_obj_list.reject! { |mod| required_modules.include?(mod.name) }
      framework.update(del_module_obj_list, :del, baseline)
      framework.integrate!
    end

    # 更新模块的操作
    #
    # @param [Array] modules 更新的模块
    # @param [MpaasFramework] framework 框架
    # @param [String] baseline 基线版本
    def update_module_to_framework(modules, framework, baseline)
      return if modules.empty?
      # 更新的模块列表
      update_module_obj_list = @baseline_manager.fetch_module_info(modules, baseline)
      framework.update(update_module_obj_list, :alt, baseline)
      framework.integrate!
    end

    # 解析框架
    #
    # @return [Array<String, MpaasFramework>]
    #         两个元素，第一个为基线版本（工程中已有/最新）
    #         第二个为生成的框架（根据原工程解析/新建空框架）
    #
    def parse_framework
      # 获取添加模块所在基线版本
      baseline_version = @resolver.resolved_current_baseline || @baseline_manager.version
      # 解析已有工程，如果是新工程，创建一个空的
      framework = @resolver.resolve do |versions_by_name, baseline_by_name|
        if basic_info.active_v4
          baseline_by_name.map { |name, baseline| @baseline_manager.fetch_module_obj(name, baseline) }.compact
        else
          names = versions_by_name.keys.map(&ModuleConfig.method(:module_name))
          @baseline_manager.fetch_module_info(names, baseline_version)
        end
      end || MpaasFramework.create_empty_framework(@project, baseline_version)
      [baseline_version, framework]
    end
  end
end
