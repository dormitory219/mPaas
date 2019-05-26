# frozen_string_literal: true

# project_generator.rb
# MpaasKit
#
# Created by quinn on 2019-01-09.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # xcode工程的管理
  #
  class ProjectGenerator
    include BasicInfo::Mixin

    # 初始化
    #
    # @param project_type [Symbol] 工程类型, 以下取值
    #                     :sys/:sys_pod/:mpaas/:mpaas_pod
    # @param app_type [Symbol] 应用类型，以下取值
    #                 :tab/:drawer/:navigation/:empty
    #
    def initialize(project_type = nil, app_type = nil)
      @project_type = project_type
      @app_type = app_type.to_s
    end

    # 创建 app 的 xcode 工程
    #
    # @return [XCProjectObject] 创建的工程对象
    #
    def create_app_project
      # 创建工程
      project = create_project
      if project.mpaas_project?
        # 设置 launcher
        add_launcher(project)
        # 分配图片资源
        dispatch_resources(project)
      end
      project
    rescue StandardError
      # 发生异常，删除输出产物
      remove_project
      raise
    end

    # 从本地路径读取工程
    #
    # @param [Pathname] xcodeproj_path 工程文件 .xcodeproj 路径
    # @param [String] target 当前编辑的 target 名称
    # @return [XCProjectObject] 工程对象
    #
    def self.load_from_path(xcodeproj_path, target)
      raise "指定的 Target 不存在: #{target}" if XcodeHelper.find_native_target(xcodeproj_path, target).nil?
      XCProjectObject.new(xcodeproj_path.basename.sub('.xcodeproj', ''), nil, xcodeproj_path.parent, target)
    end

    private

    # 删除输出产物
    #
    def remove_project
      # 强制校验工程名称，防止误删父目录
      if basic_info.project_name.nil? || basic_info.project_name.empty?
        UILogger.warning('无法获取工程名称')
        return
      end
      project_src_root = basic_info.project_path + basic_info.project_name
      UILogger.debug("创建工程异常，删除生成目录 #{project_src_root}")
      FileUtils.remove_entry(project_src_root) if project_src_root.exist?
    end

    # 创建 app 的 xcode 工程
    #
    # @return [XCProjectObject] 创建的工程对象
    #
    def create_project
      UILogger.info "创建 #{@project_type} xcode 工程"
      is_mpaas_project = %i[mpaas mpaas_pod].include?(@project_type)
      project_template = TemplatesFactory.load_template(:project, :mpaas_project => is_mpaas_project)
      project_template.edit
      project_template.save
      # 返回工程对象
      XCProjectObject.new(basic_info.project_name, @project_type,
                          project_template.destination, basic_info.active_target)
    ensure
      project_template&.close
    end

    # 设置启动 launcher
    #
    # @param project [XCProjectObject] 工程对象
    #
    def add_launcher(project)
      UILogger.info "添加启动 Launcher: #{@app_type}"
      app_template = TemplatesFactory.load_template(:app,
                                                    :app_type => @app_type, :xcodeproj => project.xcodeproj_path)
      app_template.edit
      app_template.save(project.src_root + project.active_target + 'Sources')
    ensure
      app_template&.close
    end

    # 为不同的 app 类型分配资源文件
    #
    # @param project [XCProjectObject] 工程对象
    #
    def dispatch_resources(project)
      project_resource_path = project.src_root + project.active_target + 'Resources'
      resources_for_app.each do |name|
        src_file = LocalPath.resource_dir + name
        # 拷贝文件
        FileUtils.cp(src_file, project_resource_path)
        # 添加引用
        XcodeHelper.add_file_reference(project.xcodeproj_path, project_resource_path + name)
        # 添加 build phase
        XcodeHelper.add_build_phases_ref(project.xcodeproj_path, project.active_target,
                                         XcodeHelper::RESOURCES, project_resource_path + name)
      end
    end

    # 不同 app 类型的资源文件
    #
    # @return [Array]
    #
    def resources_for_app
      resource_files = []
      if @app_type == 'drawer'
        resource_files += %w[ic_launcher.png menu_icon.png]
      elsif @app_type == 'navigation'
        resource_files << 'back_button@2x.png'
      end
      resource_files
    end
  end
end
