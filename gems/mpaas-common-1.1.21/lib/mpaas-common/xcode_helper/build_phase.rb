# frozen_string_literal: true

# build_phase.rb
# MpaasKit
#
# Created by quinn on 2019-01-09.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # xcode工程 build phase 相关操作
  #
  class XcodeHelper
    module BuildPhaseName
      # compile sources
      SOURCES = 'Sources'
      # link binary with libraries
      FRAMEWORKS = 'Frameworks'
      # copy bundle resources
      RESOURCES = 'Resources'
    end
    include BuildPhaseName

    class << self
      include BuildPhaseName

      # 从 build phases 中查找文件位置
      #
      # @param [Pathname] project_path
      # @param [String] target_name
      # @param [BuildPhaseName] phase
      # @param [String] file_name
      # @return [Pathname] 绝对路径
      #
      def search_from_build_phase(project_path, target_name, phase, file_name)
        UILogger.debug("从 build phase 中查找: #{file_name}")
        project_read(project_path) do |_|
          build_phase = build_phase(find_native_target(project_path, target_name), phase)
          ref = build_phase.files_references.find { |r| r.display_name == file_name }
          ref&.real_path
        end
      end

      # 查找文件所在的 build phase 名称
      #
      # @param [Pathname] project_path
      # @param [String] target_name
      # @param [String] file_real_path
      # @return [BuildPhaseName]
      #
      def search_build_phase_name(project_path, target_name, file_real_path)
        UILogger.debug("查找文件所在的 build phase: #{file_real_path}")
        ref = find_file_reference(project_path, file_real_path)
        native_target = find_native_target(project_path, target_name)
        native_target.build_phases.map do |phase|
          phase.display_name if phase.files_references.include?(ref)
        end.compact
      end

      # 从 build phases 中删除文件引用
      #
      # @param project_path 工程路径
      # @param target_name target 名称
      # @param phase phase 名称（BuildPhaseName 类型）
      # @param file_real_path 待删除的文件绝对路径
      #
      def remove_build_phases_ref(project_path, target_name, phase, file_real_path)
        UILogger.debug "移除 build phase: #{File.basename(file_real_path)}"
        project_write(project_path) do |_|
          build_phase = build_phase(find_native_target(project_path, target_name), phase)
          ref = find_reference(project_path, file_real_path)
          build_phase.remove_file_reference(ref) unless ref.nil? || build_phase.nil?
        end
      end

      # 向 build phases 中添加文件引用
      #
      # @param project_path 工程路径
      # @param target_name target 名称
      # @param phase phase 名称（BuildPhaseName 类型）
      # @param file_real_path 待删除的文件绝对路径
      #
      def add_build_phases_ref(project_path, target_name, phase, file_real_path)
        UILogger.debug "添加到 build phase: #{File.basename(file_real_path)}"
        project_write(project_path) do |_|
          build_phase = build_phase(find_native_target(project_path, target_name), phase)
          ref = find_reference(project_path, file_real_path)
          build_phase.add_file_reference(ref, true) unless ref.nil? || build_phase.nil?
        end
      end

      # build phases 中是否存在文件引用
      #
      # @param project_path 工程路径
      # @param target_name target 名称
      # @param phase phase 名称（BuildPhaseName 类型）
      # @param file_real_path 待删除的文件绝对路径
      # @return [Bool] 是否存在
      #
      def build_phase_ref_exist?(project_path, target_name, phase, file_real_path)
        build_phase = build_phase(find_native_target(project_path, target_name), phase)
        ref = find_reference(project_path, file_real_path)
        return false if ref.nil? || build_phase.nil?

        build_phase.files_references.include?(ref)
      end

      # 添加系统库
      #
      # @param project_path 工程路径
      # @param target_name target 名称
      # @param names 系统库的名称（可以为数组）
      #
      def add_system_frameworks(project_path, target_name, names)
        UILogger.debug "添加依赖的系统 framework: #{names}"
        project_write(project_path) do |project|
          phase = build_phase(find_native_target(project_path, target_name), FRAMEWORKS)
          sdk_root = read_xcode_build_vars(project_path, target_name, 'SDKROOT') || SystemInfo.ios_sdk_path
          frameworks_path = Pathname.new(sdk_root) + 'System/Library/Frameworks'
          Array(names).each do |name|
            path = frameworks_path + name
            ref = project.frameworks_group.find_file_by_path(path)
            unless ref
              ref = project.frameworks_group.new_file(frameworks_path + name, :sdk_root)
              phase.add_file_reference(ref, true)
            end
          end
        end
      end

      # 添加系统库
      #
      # @param project_path 工程路径
      # @param target_name target 名称
      # @param names 系统库的名称（可以为数组）
      #
      def remove_system_frameworks(project_path, target_name, names)
        UILogger.debug "移除依赖的系统 framework: #{names}"
        project_write(project_path) do |project|
          phase = build_phase(find_native_target(project_path, target_name), FRAMEWORKS)
          Array(names).each do |name|
            ref = project.frameworks_group[name]
            phase.remove_file_reference(ref) if !phase.nil? && !ref.nil?
            project.frameworks_group.remove_reference(ref) unless ref.nil?
          end
        end
      end

      private

      # 获取 build phase
      #
      # @param native_target target 对象
      # @param phase 阶段
      # @return [PBXFrameworksBuildPhase, PBXResourcesBuildPhase, PBXSourcesBuildPhase]
      #         具体的 build phase
      #
      def build_phase(native_target, phase)
        return nil if native_target.nil?

        case phase
        when SOURCES
          native_target.source_build_phase
        when FRAMEWORKS
          native_target.frameworks_build_phase
        when RESOURCES
          native_target.resources_build_phase
        else
          return nil
        end
      end
    end
  end
end
