# frozen_string_literal: true

# xcode_helper.rb
# MpaasKit
#
# Created by quinn on 2019-01-09.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # xcode工程相关操作
  #
  class XcodeHelper
    require_relative 'xcode_helper/reference'
    require_relative 'xcode_helper/build_phase'
    require_relative 'xcode_helper/build_setting'

    # xcode 工程操作的上下文，保证读写一致
    #
    class ProjectContext
      class << self
        # 获取上下文的 xcode 工程
        attr_reader :project

        # 开始上下文
        #
        # @param project_path 工程路径
        #
        def begin(project_path = nil)
          # 工程已经存在，不再创建上下文，只修改计数
          if visit_same_project(project_path)
            @b_count += 1
          else
            # 创建工程
            @project = Xcodeproj::Project.open(project_path)
            @b_count = 1
            yield @project if block_given?
          end
        end

        # 提交并结束上下文
        #
        # @param modified 是否对工程有修改（默认为 true）
        #
        def commit(modified = true)
          # 修改计数并保存修改
          @b_count -= 1
          # 保存修改
          @project.save if !@project.nil? && modified && @b_count.zero?
          # 计数为0，直接关闭上下文
          @project = nil if @b_count.zero?
        end

        private

        # 是否访问同一个工程
        #
        # @param project_path 工程路径
        # @return [Bool]
        #
        def visit_same_project(project_path)
          return false if @project.nil? || project_path.nil?
          @project.path == (project_path.absolute? ? project_path : project_path.realpath)
        end
      end
    end

    class << self
      # 开始事务处理
      # 针对 xcode 工程的批量修改操作
      #
      # @param xc_project_path .xcodeproj 工程文件路径
      # @param &block 返回 block 内部可以处理 xcode 多种修改操作
      #
      # e.g. XcodeHelper.begin_transaction('/path/to/example.xcodeproj') do |helper|
      #         helper.add_file_reference(...)
      #         helper.update_build_setting_fields(...)
      #      end
      #
      def begin_transaction(xc_project_path)
        ProjectContext.begin(xc_project_path)
        yield XcodeHelper if block_given?
        ProjectContext.commit
      end

      # 找到对应的 native target
      #
      # @param project_path 工程路径
      # @param target_name target 名称
      # @return [PBXNativeTarget] target 对象
      #
      def find_native_target(project_path, target_name)
        project_read(project_path) do |project|
          project.targets.find { |target| target.name == target_name }
        end
      end

      # 工程 target 是否可执行
      #
      # @param [String] project_path
      # @param [String] target_name
      # @return [Bool]
      #
      def target_executable?(project_path, target_name)
        native_target = find_native_target(project_path, target_name)
        native_target.launchable_target_type?
      end

      # 查找文件所在组的路径
      #
      # @param project_path 工程路径
      # @param file_real_path 查找文件的绝对路径
      # @return [String] 组的绝对路径
      #
      def find_group_path(project_path, file_real_path)
        file_ref = find_file_reference(project_path, file_real_path)
        file_ref.nil? ? nil : File.dirname(project_path) + file_ref.parent.hierarchy_path
      end

      # 读取工程中所有 target 的名称
      #
      # @return [Array<String>] target 名称数组
      #
      def all_targets_name(project_path)
        project_read(project_path) { |project| project.targets.map(&:name) }
      end

      # 解析工程的结构信息
      # workspace 包括哪些 project，project 包括哪些 target
      #
      # @param [Pathname] project_path .xcodeproj/.xcworkspace 文件路径
      # @return [Hash]
      #
      def parse_project_structure(project_path)
        name = File.basename(project_path, '.*')
        path = project_path.realpath.to_s
        if project_path.extname == '.xcworkspace'
          # workspace
          workspace = Xcodeproj::Workspace.new_from_xcworkspace(project_path)
          { :name => name, :type => 'workspace', :path => path,
            :children => workspace.file_references.map do |project_ref|
              if File.extname(project_ref.path) == '.xcodeproj'
                path = project_ref.absolute_path(File.dirname(project_path))
                parse_project_structure(Pathname.new(path)) if File.exist?(path)
              end
            end.compact }
        else
          # project
          { :name => name, :type => 'project', :path => path,
            :children => all_targets_name(project_path).map do |target_name|
              { :name => target_name, :type => 'target', :path => path, :children => [] }
            end }
        end
      end

      # 读取xcode build中的环境变量
      #
      # @param [Pathname] project_path
      # @param [String] target_name
      # @param [String] field
      # @return [Hash]
      #
      def read_xcode_build_vars(project_path, target_name, field)
        bs_reader = @readers&.find { |reader| reader.match?(project_path) }
        unless bs_reader
          @readers ||= []
          bs_reader = BuildSettingsReader.new(project_path)
          @readers << bs_reader
        end
        bs_reader.read(target_name, field)
      end

      private

      # 写工程
      #
      def project_write(project_path = nil)
        ProjectContext.begin(project_path)
        value = block_given? ? yield(ProjectContext.project) : nil
        ProjectContext.commit
        value
      end

      # 读工程
      #
      def project_read(project_path = nil)
        ProjectContext.begin(project_path)
        value = block_given? ? yield(ProjectContext.project) : nil
        ProjectContext.commit(false)
        value
      end
    end
  end
end
