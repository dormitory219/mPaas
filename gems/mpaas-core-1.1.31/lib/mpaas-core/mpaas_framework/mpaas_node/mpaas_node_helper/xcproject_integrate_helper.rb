# frozen_string_literal: true

# xcproject_integrate_helper.rb
# MpaasKit
#
# Created by quinn on 2019-02-27.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 提供 xcode 工程集成相关操作
  #
  class MpaasNode
    # 存储集成的操作类型
    # 叶子节点标记
    #
    # @param [String] target
    # @param [Symbol] operation
    #
    def store_integration_op(target, operation)
      @integration_op_hash[target] = operation
    end

    # 处理 xcode 工程集成
    #
    # @param [Pathname] xcodeproj_path .xcodeproj 工程文件目录（绝对路径）
    # @param [String] target target 名称
    #
    def handle_xcproject_integration(xcodeproj_path, target)
      # 根据节点内部状态执行不同的操作
      if need_remove?(target)
        # 先处理子节点，再移除本身
        each_child { |child_node| child_node.handle_xcproject_integration(xcodeproj_path, target) }
        UILogger.debug("工程移除节点: #{path}")
        remove_from_project(xcodeproj_path, target)
        return
      elsif need_update?(target)
        # 更新自身，再处理子节点
        UILogger.debug("工程更新节点: #{path}")
        update_to_project(xcodeproj_path, target)
      elsif need_integrate?(xcodeproj_path, target)
        # 先添加本身，再处理子节点
        UILogger.debug("工程添加节点: #{path}")
        add_to_project(xcodeproj_path, target)
      else
        UILogger.debug("无需处理节点: #{path}")
      end
      each_child { |child_node| child_node.handle_xcproject_integration(xcodeproj_path, target) }
    end

    protected

    # 更新到工程中
    # 默认不处理，只有 framework 会处理
    #
    # @param [Pathname] _xcodeproj_path .xcodeproj 工程文件目录（绝对路径）
    # @param [String] _target target 名称
    #
    def update_to_project(_xcodeproj_path, _target); end

    # 从工程中移除
    #
    # @param [Pathname] xcodeproj_path .xcodeproj 工程文件目录（绝对路径）
    # @param [String] target target 名称
    #
    def remove_from_project(xcodeproj_path, target)
      # 先移除 build phase，再移除文件引用，避免 build phase 中出现 nil
      remove_build_phase(xcodeproj_path, target)
      remove_reference(xcodeproj_path)
    end

    # 添加到工程中
    #
    # @param [Pathname] xcodeproj_path .xcodeproj 工程文件目录（绝对路径）
    # @param [String] target target 名称
    #
    def add_to_project(xcodeproj_path, target)
      # 先添加引用，再添加 build phase
      add_reference(xcodeproj_path)
      add_build_phase(xcodeproj_path, target)
    end

    # 是否需要集成
    #
    # @param [Pathname] xcodeproj_path .xcodeproj 工程文件目录（绝对路径）
    # @param [String] target target 名称
    # @return [Bool]
    #
    def need_integrate?(xcodeproj_path, target)
      # 组节点，原有逻辑，判断文件引用和 build phase 同时存在
      return (!reference_exist?(xcodeproj_path) || !build_phase_exist?(xcodeproj_path, target)) unless leaf?
      # 叶子节点按标记处理
      op = @integration_op_hash.fetch(target, nil)
      # 如果没有存储标记，直接判断引用
      op.nil? ? false : op == :add
    end

    # 是否需要从工程中移除
    #
    # @param [String] target
    # @return [Bool]
    #
    def need_remove?(target)
      # 组节点按原有逻辑
      return remove_flag unless leaf?
      # 叶子节点按标记处理
      op = @integration_op_hash.fetch(target, nil)
      # 如果没有存储标记，直接使用移除标记
      op.nil? ? false : op == :del
    end

    # 是否需要更新
    #
    # @param [String] target
    # @return [Bool]
    #
    def need_update?(target)
      # 组节点按原有逻辑
      return !@update_content.nil? unless leaf?
      # 叶子节点按标记处理
      op = @integration_op_hash.fetch(target, nil)
      # 如果没有存储标记，当前target中不处理
      op.nil? ? false : op == :alt
    end
  end
end
