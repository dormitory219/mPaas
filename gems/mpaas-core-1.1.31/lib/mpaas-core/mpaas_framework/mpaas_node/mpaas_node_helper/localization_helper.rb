# frozen_string_literal: true

# localization_helper.rb
# MpaasKit
#
# Created by quinn on 2019-01-13.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 提供节点本地化的相关操作
  #
  class MpaasNode
    # 本地化的文件是否存在，标记之前是不是 copy 模式
    # !!注意，只有在本地化之后才可以使用
    #
    attr_reader :localized_file_exist
    alias localized_file_exist? localized_file_exist

    # 标记本地化删除
    #
    def mark_remove_flag
      @remove_flag = true
    end

    # 执行本地化
    #
    # @param project_src_root [Pathname] 工程目录（绝对路径）
    #
    def apply_localization(project_src_root)
      # 解析本地化文件是否存在, 每个节点标记一次
      update_localized_status(project_src_root)
      # 根据节点当前的状态处理不同的逻辑
      if remove_flag
        # 删除节点
        # 子节点依次处理
        each_child { |child_node| child_node.apply_localization(project_src_root) }
        perform_remove(project_src_root)
        return
      elsif !@update_content.nil?
        # 更新节点
        perform_update(project_src_root)
      elsif need_write(project_src_root)
        # 写节点
        perform_write(project_src_root)
      else
        UILogger.debug("无需写入节点: #{path}")
      end
      # 子节点依次处理
      each_child { |child_node| child_node.apply_localization(project_src_root) }
    end

    protected

    attr_reader :remove_flag

    # 更新本地化文件状态
    #
    # @param [Pathname] project_src_root
    #
    def update_localized_status(project_src_root)
      @localized_file_exist ||= (project_src_root + path).exist?
      # 递归每个子节点去保存
      each_child { |child_node| child_node.update_localized_status(project_src_root) }
    end

    # 是否需要写入节点
    #
    # @param [Pathname] _project_src_root 工程目录（绝对路径）
    # @return [Bool]
    #
    def need_write(_project_src_root)
      !@localized_file_exist
    end

    # 节点本地化写入
    #
    # @param project_src_root [Pathname] 工程目录（绝对路径）
    #
    def perform_write(project_src_root)
      # 子类实现
      UILogger.debug "写入节点: #{path}"
      write(project_src_root)
    ensure
      content_template&.close
    end

    # 节点本地化更新
    #
    # @param project_src_root [Pathname] 工程目录（绝对路径）
    #
    def perform_update(project_src_root)
      # 子类实现
      UILogger.debug "更新节点: #{path}"
      update(project_src_root)
    ensure
      update_content_template&.close
    end

    # 节点本地化删除
    #
    # @param project_src_root [Pathname] 工程目录（绝对路径）
    #
    def perform_remove(project_src_root)
      UILogger.debug "删除节点: #{path}"
      # 子类实现
      remove(project_src_root)
    end

    # 节点新建
    # 抽象方法，子类实现
    #
    # @param _project_src_root [Pathname] 工程目录（绝对路径）
    #
    def write(_project_src_root); end

    # 节点的删除操作
    # !! 只删除实体文件，并不会改变节点树结构
    # 抽象方法，子类实现，默认实现为删除 path 对应的实体文件
    #
    # @param project_src_root [Pathname] 工程目录（绝对路径）
    #
    def remove(project_src_root)
      # 直接删除实体文件/目录
      FileUtils.remove_entry(project_src_root + path) if (project_src_root + path).exist?
    end

    # 节点更新
    # 抽象方法，子类实现
    #
    # @param _project_src_root [Pathname] 工程目录（绝对路径）
    #
    def update(_project_src_root); end
  end
end
