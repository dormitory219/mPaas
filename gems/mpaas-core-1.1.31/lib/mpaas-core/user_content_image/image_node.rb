# frozen_string_literal: true

# image_node.rb
# workspace
#
# Created by quinn on 2019-03-25.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 镜像节点
  #
  class ImageNode
    # 初始化
    #
    # @param [String] path
    # @param [String] target
    # @param [BuildPhaseName] phases
    # @param [String] force
    #
    def initialize(path, target, phases, force = false)
      @path = path          # 原始路径
      @phase_names = phases # 原始文件在工程中的 build phase 数组
      @target = target      # 对应的 target
      @force = force        # 是否强制还原
    end

    attr_reader :path, :phase_name, :target, :force

    # 从工程中移除
    #
    # @param [Pathname] xcodeproj_path
    #
    def remove_from_project(xcodeproj_path)
      # 引用不存在则不处理
      return unless XcodeHelper.file_reference_exist?(xcodeproj_path, @path)
      # 移除 build phase
      @phase_names.each { |phase| XcodeHelper.remove_build_phases_ref(xcodeproj_path, @target, phase, @path) }
      # 移除引用
      XcodeHelper.remove_file_reference(xcodeproj_path, @path)
    end

    # 还原镜像到工程中
    #
    # @param [Pathname] xcodeproj_path
    #
    def recover_to_project(xcodeproj_path)
      # 引用存在就不再还原
      return if XcodeHelper.file_reference_exist?(xcodeproj_path, @path)
      # 还原引用
      XcodeHelper.add_file_reference(xcodeproj_path, @path)
      # 还原 build phase
      @phase_names.each { |phase| XcodeHelper.add_build_phases_ref(xcodeproj_path, @target, phase, @path) }
    end
  end
end
