# frozen_string_literal: true

# framework_node.rb
# MpaasKit
#
# Created by quinn on 2019-01-12.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 链接库节点
  # .framework 文件
  # 需要操作 build phases 的 Frameworks 阶段
  #
  class FrameworkNode < MpaasNode
    def need_write(_project_src_root)
      # framework 每次都写入
      true
    end

    def write(project_src_root)
      # 先将原有文件删除
      remove(project_src_root)
      # 写入模式（copy），将本地基线目录下的文件拷贝到工程目录下
      FileUtils.cp_r(content_location, project_src_root + path) if @writable && content_location
    end

    def remove(project_src_root)
      FileUtils.remove_entry(project_src_root + path) if @localized_file_exist
    end

    def update(project_src_root)
      # 先将原存在的文件删除，在拷贝新的
      remove(project_src_root)
      # 写入模式（copy），将本地基线目录下的文件拷贝到工程目录下
      FileUtils.cp_r(update_content_location, project_src_root + path) if @writable && update_content_location
    end

    def add_to_project(xcodeproj_path, target)
      # 如果存在，将原有引用删除，防止切换 copy 状态时，残留引用
      remove_from_project(xcodeproj_path, target) if reference_exist?(xcodeproj_path)
      super(xcodeproj_path, target)
    end

    def update_to_project(xcodeproj_path, target)
      # 先移除旧的，再添加新的
      remove_from_project(xcodeproj_path, target)
      # 添加引用
      add_reference_with_location(xcodeproj_path, update_content_location)
      # 添加 build phase
      add_build_phase_with_location(xcodeproj_path, target, update_content_location)
    end

    def need_integrate?(xcodeproj_path, target)
      # 前后的 copy 状态不一致，需要重新集成
      (@localized_file_exist ^ @writable) || super(xcodeproj_path, target)
    end

    def reference_path(xcodeproj_path)
      @localized_file_exist ? xcodeproj_path.parent + path : content_location
    end

    def add_reference(xcodeproj_path)
      add_reference_with_location(xcodeproj_path, content_location)
    end

    def add_build_phase(xcodeproj_path, target)
      add_build_phase_with_location(xcodeproj_path, target, content_location)
    end

    def build_phase_name
      XcodeHelper::FRAMEWORKS
    end

    private

    # 添加引用
    #
    # @param [Pathname] xcodeproj_path
    # @param [String] location
    #
    def add_reference_with_location(xcodeproj_path, location)
      # 不可写模式，直接添加原始位置路径的引用
      full_path = @writable ? xcodeproj_path.parent + path : location
      group_path = xcodeproj_path.parent + parent.path
      XcodeHelper.add_file_reference(xcodeproj_path, full_path, group_path, false, :absolute)
    end

    # 添加 build phase
    #
    # @param [Pathname] xcodeproj_path
    # @param [String] location
    #
    def add_build_phase_with_location(xcodeproj_path, target, location)
      # 不可写模式，直接添加原始位置路径的引用
      full_path = @writable ? xcodeproj_path.parent + path : location
      XcodeHelper.add_build_phases_ref(xcodeproj_path, target, build_phase_name, full_path)
    end
  end
end
