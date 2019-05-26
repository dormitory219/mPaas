# frozen_string_literal: true

# mpaas_framework.rb
# MpaasKit
#
# Created by quinn on 2019-01-11.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # mpaas 框架结构
  #
  # MPaaS
  #  | - mpaas_sdk.config
  #  | - Targets
  #  |    | - target1
  #  |    |    | - Target-mPaaS-Headers.h
  #  |    |    | - Target-Prefix.h
  #  |    |    | - module1
  #  |    |    |    | - category files
  #  |    |    |    | - resource files
  #  |    |    | - module2
  #  |    |    |    | - category files
  #  |    |    |    | - resource files
  #  |    |    | - module3
  #  |    |    | - meta.json
  #  |    |    | - yw_1222.jpg
  #  |    | - target2
  #  | - Frameworks
  #  | - Resources
  #
  class MpaasFramework
    require_relative 'mpaas_framework/node_generator'
    require_relative 'mpaas_framework/info_plist_injector'
    require_relative 'mpaas_framework/build_setting_handler'
    require_relative 'mpaas_framework/config_data_controller'
    require_relative 'mpaas_framework/extra_action'
    require_relative 'mpaas_framework/part/mpaas_framework_system'

    include BasicInfo::Mixin

    # 初始化
    #
    # @param project [XCProjectObject] 工程对象
    #
    def initialize(project)
      @project = project
      @node_generator = NodeGenerator.new(project)
      @build_setting_handler = BuildSettingHandler.new(project)
      @config_data_controller = ConfigDataController.new(project)
      @extra_action = ExtraAction.new(project)
      @root = nil # 当前框架根节点
      @mpaas_info = nil # 当前的框架信息
      @op = nil # 当前操作
    end

    # 加载工程，从工程的配置信息中构造 已有工程的 mpaas 框架
    #
    # @param project [XCProjectObject] 工程对象
    # @param mpaas_info [MpaasInfo] mpaas 框架信息
    # @return [MpaasFramework] 框架实例
    #
    def self.load_project_info(project, mpaas_info)
      UILogger.section_info('加载工程 mpaas 框架')
      framework = new(project)
      framework.construct(mpaas_info)
      framework
    end

    # 创建一个空的框架
    #
    # @param project [XCProjectObject] 工程对象
    # @param baseline [String] 基线版本号
    # @return [MpaasFramework] 框架实例
    #
    def self.create_empty_framework(project, baseline)
      UILogger.section_info('创建空的 mpaas 框架')
      framework = new(project)
      framework.construct(MpaasInfo.new(project, baseline))
      framework
    end

    # 构造框架，生成节点
    #
    # @param mpaas_info [MpaasInfo] mpaas 框架信息
    #
    def construct(mpaas_info)
      @mpaas_info = mpaas_info
      @root = @node_generator.generate(mpaas_info)
      # 读取当前target原始的云端配置数据文件
      app_info_node = @root.find(@project.active_target).find(Constants::APP_INFO_FILE_NAME)
      @config_data_controller.load_origin_data(@project.src_root + app_info_node.path) if app_info_node
    end

    # 导入数据
    #
    def import_data
      # 先集成进工程
      integrate!
      # 更新分类文件中的配置
      target_node = @root.find(@project.active_target)
      @config_data_controller.import_data(@project.src_root + target_node.path)
    end

    # 更新框架信息，重新生成节点
    #
    # @param modules [Array<ModuleObject>] 模块对象数组
    # @param operation 整体框架的操作类型，新增，删除，更新
    #                  :add/:del/:alt
    # @param baseline 更新的基线版本号
    #
    def update(modules, operation, baseline)
      @op = operation
      @mpaas_info.update(modules, baseline, operation == :del)
    end

    # 将框架集成到工程中
    # 每一次集成针对增删改其中的一种操作
    #
    def integrate!
      UILogger.section_info('开始集成到 Xcode 工程')
      # 更新只改变mpaas info，集成的时候才去生成节点
      @root = @node_generator.regenerate(@mpaas_info)
      # 本地化
      localize
      # 整合到工程中
      integrate_in_xcproject
    end

    # 将集成的框架移除
    #
    def deintegrate!
      UILogger.section_info('开始从 Xcode 工程中去除集成')
      # 当前操作指定为删除
      @op = :del
      # 删除每个target节点下的模块和分类文件节点
      UILogger.info('所有节点标记删除')
      @project.targets.each { |target_name| @root.fully_remove(target_name) }
      # 顺序和集成顺序相反
      # 本地化
      localize
      # 从 xcode 工程去除
      deintegrate_from_xcproject
    end

    # 需要恢复的文件
    # 框架目录下的非框架节点
    #
    # @return [Array<ImageNode>]
    #
    def recovery_image_nodes
      UILogger.section_info('扫描待恢复节点')
      @project.mpaas_targets.flat_map do |target|
        # 转换无线保镖图片节点
        sg_image_node = convert_sg_image(target)
        # 扫描需要恢复的文件
        @root.scan_recovery_node(@project.xcodeproj_path, target) + Array(sg_image_node)
      end.uniq
    end

    private

    # 转换无线保镖图片节点
    #
    # @param [String] target
    # @return [ImageNode,nil]
    #
    def convert_sg_image(target)
      target_node = @root.find(target)
      sg_image_node = target_node&.find(Constants::SG_IMAGE_FILE_NAME)
      return nil if sg_image_node.nil?
      # 转换成镜像节点
      sg_image_path = @project.src_root + sg_image_node.path
      phase_name = XcodeHelper.search_build_phase_name(@project.xcodeproj_path, target, sg_image_path)
      ImageNode.new(sg_image_path, target, phase_name, true)
    end

    # 本地化，将模型写入成实体文件
    #
    def localize
      UILogger.section_info('本地化 mpaas 框架')
      @root.apply_localization(@project.src_root)
    end

    # 整合到工程中
    #
    def integrate_in_xcproject
      UILogger.section_info('将 mpaas 框架整合到 xcode 工程')
      xc_project_path = @project.xcodeproj_path
      @project.mpaas_targets.each do |target|
        UILogger.info "处理 Target: #{target}"
        # 添加引用和 build phase
        @root.handle_xcproject_integration(xc_project_path, target)
        # 如果框架为空，不进行后续操作
        next if @mpaas_info.empty?
        # 处理工程配置
        integrate_mpaas_config(target)
      end
    end

    # 为 target 集成 mpaas 的相关工程配置
    #
    # @param [String] target_name
    #
    def integrate_mpaas_config(target_name)
      target_info = @mpaas_info[target_name]
      # 处理系统库依赖
      handle_system_dependencies(target_info, target_name)
      # 修改 build setting
      @build_setting_handler.handle_build_settings(@root, target_name, target_info)
      # 注入 info.plist
      @config_data_controller.inject_mpaas_info(target_name)
      # 额外操作，如添加 crash 收集代码
      @extra_action.perform_after_integrate(target_name, target_info)
    end

    # 从工程中分离
    #
    def deintegrate_from_xcproject
      UILogger.section_info('将 mPaaS 框架从 xcode 工程中去除')
      xc_project_path = @project.xcodeproj_path
      @project.mpaas_targets.each do |target|
        UILogger.info "处理 Target: #{target}"
        # 添加引用和 build phase
        @root.handle_xcproject_integration(xc_project_path, target)
        target_info = @mpaas_info[target]
        # 移除系统库
        remove_system_dependencies(target_info, target)
        # 删除 build setting
        @build_setting_handler.remove_build_settings(@root, target, target_info)
        # 删除 info.plist 信息
        @config_data_controller.remove_mpaas_info(target)
        # 额外操作，如移除 crash 收集代码，去除 pch 中引用的 header
        @extra_action.perform_after_deintegrate(target, target_info)
      end
    end
  end
end
