# frozen_string_literal: true

# reference.rb
# MpaasKit
#
# Created by quinn on 2019-01-09.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # xcode工程引用相关操作
  #
  class XcodeHelper
    class << self
      # 文件引用是否存在
      #
      # @param project_path 工程路径
      # @param file_real_path 查找的文件绝对路径
      # @param group_real_path 查找文件所在的组路径
      # @return [Bool]
      #
      def file_reference_exist?(project_path, file_real_path, group_real_path = nil)
        if group_real_path.nil?
          !find_file_reference(project_path, file_real_path).nil?
        else
          group_ref = find_group_reference(project_path, group_real_path)
          !group_ref.nil? && !group_ref[File.basename(file_real_path)].nil?
        end
      end

      # 查找引用
      # 文件引用存在返回文件引用，否则，再查找组引用
      #
      # @param project_path 工程路径
      # @param file_real_path 查找的文件绝对路径
      # @return [PBXFileReference, PBXGroup]
      #
      def find_reference(project_path, file_real_path)
        find_file_reference(project_path, file_real_path) ||
          find_group_reference(project_path, file_real_path)
      end

      # 查找文件引用
      #
      # @param project_path 工程路径
      # @param file_real_path 查找的文件绝对路径
      # @return [PBXFileReference] 文件引用
      #
      def find_file_reference(project_path, file_real_path)
        project_read(project_path) do |project|
          src_root = Pathname.new(project_path).parent
          relative_path = Pathname.new(file_real_path).relative_path_from(src_root)
          project[relative_path.to_s] || project.files.find do |ref|
            file_ref_parent_safe(ref) && ref.real_path == file_real_path
          end
        end
      end

      # 删除文件引用
      #
      # @param project_path 工程路径
      # @param file_real_path 查找的文件绝对路径
      #
      def remove_file_reference(project_path, file_real_path)
        UILogger.debug "删除文件引用: #{File.basename(file_real_path)}"
        project_write(project_path) do |_|
          file_ref = find_file_reference(project_path, file_real_path)
          file_ref&.remove_from_project
        end
      end

      # 添加文件引用
      #
      # @param project_path 工程路径
      # @param file_real_path 添加的文件绝对路径
      # @param group_real_path 引用所属组的绝对路径（默认为文件路径的目录）
      # @param create_group 是否创建对应 group
      # @param source_tree 文件引用 location 关系（:group/:absolute）
      #
      def add_file_reference(project_path, file_real_path, group_real_path = nil,
                             create_group = false, source_tree = :group)
        UILogger.debug "添加文件引用: #{File.basename(file_real_path)}"
        group_real_path ||= File.dirname(file_real_path)
        project_write(project_path) do |_|
          group_ref = find_group_reference(project_path, group_real_path, create_group)
          group_ref&.new_file(file_real_path, source_tree)
        end
      end

      # 添加 group 引用
      #
      # @param project_path 工程路径
      # @param file_real_path 查找的文件绝对路径
      #
      def add_group_reference(project_path, file_real_path)
        UILogger.debug "添加组引用: #{File.basename(file_real_path)}"
        find_group_reference(project_path, file_real_path, true)
      end

      # 查找 group 引用
      #
      # @param project_path 工程路径
      # @param file_real_path 查找的文件绝对路径
      # @param need_create 是否创建找不到的 group
      # @return [PBXGroup] 组引用
      #
      def find_group_reference(project_path, file_real_path, need_create = false)
        # 相对工程 src root 的路径
        src_root = Pathname.new(project_path).parent
        relative_path = Pathname.new(file_real_path).relative_path_from(src_root)
        project_write(project_path) do |project|
          group_ref = project.main_group.find_subpath(relative_path.to_s, need_create)
          group_ref.set_path(File.basename(file_real_path)) if !group_ref.nil? && group_ref.path.nil?
          group_ref
        end
      end

      # 删除组引用
      #
      # @param project_path 工程路径
      # @param file_real_path 查找的文件绝对路径
      #
      def remove_group_reference(project_path, file_real_path)
        UILogger.debug "删除组引用: #{File.basename(file_real_path)}"
        project_write(project_path) do |_|
          group_ref = find_group_reference(project_path, file_real_path)
          group_ref&.remove_from_project
        end
      end

      private

      # 文件引用的父节点是否正确
      #
      # @param [PBXFileReference] ref
      # @return [Bool]
      #
      def file_ref_parent_safe(ref)
        ref.parent.is_a?(Xcodeproj::Project::Object::PBXFileReference) ||
          ref.parent.is_a?(Xcodeproj::Project::Object::PBXGroup)
      end
    end
  end
end
