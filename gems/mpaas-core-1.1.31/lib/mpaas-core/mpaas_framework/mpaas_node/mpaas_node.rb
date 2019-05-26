# frozen_string_literal: true

# mpaas_node.rb
# MpaasKit
#
# Created by quinn on 2019-01-12.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # mpaas 基本节点结构
  #
  class MpaasNode
    require_relative 'mpaas_node_helper/content_helper'
    require_relative 'mpaas_node_helper/localization_helper'
    require_relative 'mpaas_node_helper/reference_helper'
    require_relative 'mpaas_node_helper/build_phase_helper'
    require_relative 'mpaas_node_helper/xcproject_integrate_helper'

    # 初始化
    #
    # @param name 节点名称
    # @param content 节点的内容（模版/文件内容/来源路径位置/nil）
    # @param writable 节点是否可写（默认可写）
    #
    def initialize(name, content = nil, writable = true)
      @name = name
      @content = content
      @update_content = nil # 更新的 content 值
      @writable = writable
      @children = []  # 子节点列表
      @parent = nil   # 父节点，根节点的父节点为 nil
      @remove_flag = false # 是否移除标记
      @integration_op_hash = {} # 集成到工程的操作类型
    end

    attr_accessor :parent
    attr_reader :name, :children
    attr_writer :update_content

    # 添加子节点
    #
    # @param nodes [MpaasNode, Array<MpaasNode>] 子节点 node
    #
    def append_child(nodes)
      Array(nodes).each do |node|
        node.parent = self
        @children << node
      end
    end

    # 从树结构中移除
    #
    def remove_from_root
      return if !leaf? || parent.nil?
      # 从父节点中移除
      parent.children.delete(self)
      @parent = nil
    end

    # 查找某节点
    # 遍历该节点和所有子节点
    #
    # @param search_name  节点名称
    # @return [MpaasNode, nil]
    #
    def find(search_name)
      res_node = node_match(search_name) ? self : nil
      each_child do |child_node|
        res_node ||= child_node.find(search_name)
        break unless res_node.nil?
      end
      res_node
    end

    # 插入子节点
    #
    # @param index [Integer] 插入位置
    # @param node [MpaasNode] 子节点 node
    #
    def insert_child(index, node)
      node.parent = self
      @children.insert(index, node)
    end

    # 是否为叶子节点
    # 除 GroupNode 之外的节点都是叶子节点
    #
    def leaf?
      @children.empty?
    end

    # 遍历每一个子节点
    #
    def each_child
      children.each { |node| yield node if block_given? } unless leaf?
    end

    # 关闭
    # 清理节点
    #
    def close
      # 关闭自身模版
      content_template&.close
      update_content_template&.close
    end

    # 节点的路径
    # xcode 工程 src root 的相对路径，从根节点到当前节点
    #
    # @return [String] 路径
    # e.g. Targets 节点的路径为 MPaaS/Targets
    #      根节点的路径为节点名称
    #
    def path
      @path ||= (parent.nil? ? name : Pathname.new(parent.path) + name).to_s
    end

    # 完全标记为删除，包括本地化和集成阶段
    #
    # @param [String] target
    #
    def fully_remove(target)
      # 先标记自己移除和引用删除
      mark_remove_flag
      store_integration_op(target, :del)
      # 遍历子节点处理
      each_child { |chile_node| chile_node.fully_remove(target) }
    end

    # 查找非框架节点，待恢复节点
    #
    # @param [Pathname] xcodeproj_path
    # @return [Array<ImageNode>] 恢复文件的路径数组
    #
    def scan_recovery_node(xcodeproj_path, target_name)
      return [] if leaf?
      project_src_root = xcodeproj_path.parent
      # 递归查找子节点的文件
      recovery_list = @children.flat_map do |child_node|
        child_node.scan_recovery_node(xcodeproj_path, target_name)
      end
      # 查找当前节点下的文件
      find_root = project_src_root + path
      # 遍历对应的实体目录
      recovery_list + Dir.glob(find_root.to_s + '/**').map do |p|
        relative_path = Pathname.new(p).relative_path_from(project_src_root)
        # 如果文件为框架节点，则不处理
        next if !ModuleConfig.force_recovery_category.include?(@name) &&
                @children.map(&:path).map(&:to_s).include?(relative_path.to_s)
        phase_name = XcodeHelper.search_build_phase_name(xcodeproj_path, target_name, p)
        ImageNode.new(p, target_name, phase_name)
      end.compact
    end

    protected

    # 查找节点的匹配规则
    # 节点全名，节点扩展名
    #
    # @param search_name 查找的名称
    # @return [Bool]
    #
    def node_match(search_name)
      search_name.start_with?('.') ? @name.end_with?(search_name) : @name == search_name
    end
  end
end
