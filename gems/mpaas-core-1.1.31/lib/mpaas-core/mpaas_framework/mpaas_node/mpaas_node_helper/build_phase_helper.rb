# frozen_string_literal: true

# build_phase_helper.rb
# MpaasKit
#
# Created by quinn on 2019-02-27.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 提供节点在工程 build phase 的相关操作
  #
  class MpaasNode
    protected

    # build phase 是否存在
    #
    # @param [Pathname] xcodeproj_path .xcodeproj 工程文件目录（绝对路径）
    # @param [String] target 当前的 target
    # @return [Bool]
    #
    def build_phase_exist?(xcodeproj_path, target)
      # 不需要增加 build phase 直接返回 true
      return true if build_phase_name.nil?
      # 判断是否存在
      XcodeHelper.build_phase_ref_exist?(xcodeproj_path, target, build_phase_name, reference_path(xcodeproj_path))
    end

    # 添加到工程的 build phase
    # 抽象方法，子类覆盖实现
    #
    # @param [Pathname] xcodeproj_path .xcodeproj 工程文件目录（绝对路径）
    # @param [String] target 当前的 target
    #
    def add_build_phase(xcodeproj_path, target)
      # 如果 build phase 存在，不处理，避免重复添加
      return if build_phase_name.nil? || build_phase_exist?(xcodeproj_path, target)
      # 添加 build phase
      XcodeHelper.add_build_phases_ref(xcodeproj_path, target, build_phase_name, reference_path(xcodeproj_path))
    end

    # 从工程的 build phase 移除
    # 抽象方法，子类覆盖实现
    #
    # @param [Pathname] xcodeproj_path .xcodeproj 工程文件目录（绝对路径）
    # @param [String] target 当前的 target
    #
    def remove_build_phase(xcodeproj_path, target)
      return if build_phase_name.nil?
      # 移除 build phase
      XcodeHelper.remove_build_phases_ref(xcodeproj_path, target, build_phase_name, reference_path(xcodeproj_path))
    end

    # 节点需要添加的 build phase name
    #
    # @return [XCodeHelper::BuildPhaseName]
    #
    def build_phase_name; end
  end
end
