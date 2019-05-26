# frozen_string_literal: true

# module_manager.rb
# MpaasKit
#
# Created by quinn on 2019-01-11.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 管理模块的添加和修改
  #
  class ModuleManager
    require_relative 'module_manager/module_manager_private'
    require_relative 'module_manager/module_manager_validate'
    require_relative 'module_manager/module_manager_required'
    require_relative 'module_manager/module_manager_update'

    include BasicInfo::Mixin

    # 初始化
    #
    # @param [XCProjectObject] project 待管理的当前工程对象
    #
    def initialize(project)
      @project = project
      @user_content_image = UserContentImage.new(project)
      @resolver = Resolver.new(project)
      @baseline_manager = BaselineManager.new
      # 校验新特性
      @baseline_manager.check_new_feature(@resolver.resolved_current_baseline)
      # 检查基线版本更新状态
      @baseline_manager.check_for_updates
    end

    # 导入云端数据
    #
    def import_data
      # 创建空的框架，只添加 app info 节点，无线保镖节点
      baseline = @resolver.resolved_current_baseline || @baseline_manager.version
      framework = MpaasFramework.create_empty_framework(@project, baseline)
      framework.import_data
    end

    # 更新整个基线
    #
    # @param [String] baseline 基线（latest 表示最新基线）
    #
    def update_all_modules(baseline)
      modules = @resolver.resolve_all_installed_modules
      return if modules.empty?
      # 升级基线，所有 target 全升
      BackupKit.backup(@project) do
        # 不用新特性解析旧工程
        baseline_version, framework = parse_framework
        # 生成用户内容镜像
        UserContentImage.build_and_recover(@project) do |uc_image|
          uc_image.build(framework.recovery_image_nodes)
          # 完全去框架，旧工程的框架，在这之后再使用新特性
          framework.deintegrate!
          # 升基线，设置为新特性，检查更新
          @baseline_manager.check_new_feature(nil)
          @baseline_manager.check_for_updates
          # 取最新基线
          baseline = @baseline_manager.version if baseline == 'latest'
          UILogger.info("从 #{baseline_version} 升级到 #{baseline}")
          # 用最新基线，重新添加模块
          add_module(*modules)
        end
      end
    end

    # 更新模块
    #
    def update_module(*modules)
      # 入口处转换名称
      modules = modules.map(&ModuleConfig.method(:module_name))
      return if modules.empty?
      # 更新
      UILogger.section_info('开始更新模块')
      # 校验基线版本
      validate_update_baseline
      # 校验target
      validate_active_target
      UILogger.debug("更新模块: #{modules.join(', ')}")
      # 备份
      BackupKit.backup(@project) do
        baseline_version, framework = parse_framework
        # v4 支持跨基线更新，取最新基线
        baseline_version = @baseline_manager.version if basic_info.active_v4
        update_modules = extract_update_modules(modules)
        # v4 支持的格式
        update_modules = update_modules.map { |name| [name, baseline_version] } if basic_info.active_v4
        update_module_to_framework(update_modules, framework, baseline_version) unless update_modules.empty?
      end
      true
    end

    # 添加模块
    #
    # @param modules [Array] 添加的模块数组，可指定版本，默认为最新版本
    # e.g. [name1, name2, ....]
    #      [[name1, version], [name2, version], ...]
    #
    def add_module(*modules)
      # 入口处转换模块名称
      modules = (modules.map(&ModuleConfig.method(:module_name)) + required_modules).uniq
      return if modules.empty?
      # 新建模块
      UILogger.section_info('开始新建模块')
      UILogger.debug("新建模块: #{modules.join(', ')}")
      # 新增模块直接用最新基线，创建空的框架
      baseline_version = @baseline_manager.version
      framework = MpaasFramework.create_empty_framework(@project, baseline_version)
      # v4 模式的结构
      modules = modules.map { |name| [name, baseline_version] } if basic_info.active_v4
      add_module_to_framework(modules, framework, baseline_version)
    end

    # 编辑模块
    #
    # @param [Array] add_modules 添加的模块
    # @param [Array] del_modules 删除的模块
    # # e.g. [name1, name2, ....]
    #
    def edit_module(add_modules, del_modules)
      # 入口处转换名称
      add_modules = add_modules.map(&ModuleConfig.method(:module_name))
      del_modules = del_modules.map(&ModuleConfig.method(:module_name))
      # 没有任何模块不处理
      return if add_modules.empty? && del_modules.empty?
      # 编辑
      UILogger.section_info('开始编辑模块')
      UILogger.debug("编辑模块: [新增] #{add_modules.join(', ')}") unless add_modules.empty?
      UILogger.debug("编辑模块: [移除] #{del_modules.join(', ')}") unless del_modules.empty?
      # 备份
      BackupKit.backup(@project) do
        # 先添加，后移除
        baseline_version, framework = parse_framework
        # 兼容 v4
        if basic_info.active_v4
          # 直接取最新版本，跨基线
          baseline_version = @baseline_manager.version
          # 数据格式
          add_modules = add_modules.map { |name| [name, baseline_version] }
          del_modules = del_modules.map { |name| [name, baseline_version] }
        end
        add_module_to_framework(add_modules, framework, baseline_version)
        remove_module_from_framework(del_modules, framework, baseline_version)
      end
    end

    # 删除模块
    #
    def remove_module(*modules)
      # 入口处转换名称
      modules = modules.map(&ModuleConfig.method(:module_name))
      return if modules.empty?
      # 校验target
      validate_active_target
      # 删除
      UILogger.section_info('开始删除模块')
      baseline_version, framework = parse_framework
      # 兼容 v4 数据
      modules = modules.map { |name| [name, baseline_version] } if basic_info.active_v4
      remove_module_from_framework(modules, framework, baseline_version)
    end

    # 查找模块
    #
    def search_module
      ''
    end
  end
end
