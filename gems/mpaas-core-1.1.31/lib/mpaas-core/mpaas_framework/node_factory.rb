# frozen_string_literal: true

# node_factory.rb
# MpaasKit
#
# Created by quinn on 2019-01-12.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 节点工厂
  #
  module NodeFactory
    require_relative 'mpaas_node/mpaas_node'
    require_relative 'mpaas_node/group_node'
    require_relative 'mpaas_node/normal_node'
    require_relative 'mpaas_node/source_node'
    require_relative 'mpaas_node/framework_node'
    require_relative 'mpaas_node/resource_node'

    class << self
      # 创建节点
      #
      # @param type [Symbol] 节点类型（:normal :source :framework :resource :group）
      #             :normal 普通文件节点（叶子节点），不需要操作 build phase
      #             :source 源文件节点（叶子节点），需要操作 build phases 的 Sources 阶段
      #             :framework 链接库文件节点（叶子节点），需要操作 build phases 的 Frameworks 阶段
      #             :resource 资源文件节点（叶子节点），需要操作 build phases 的 Resources 阶段
      #             :group 目录文件节点（枝节点）
      # @param name 节点名称
      # @param content 节点内容（模版 BaseTemplate，字符串内容 String，来源路径位置 Pathname，默认为 nil）
      # @param writable 节点是否可写（默认为 true）
      # @return [MpaasNode] 创建的节点实例
      #
      def create(type, name, content = nil, writable = true)
        case type
        when :normal
          NormalNode.new(name, content, writable)
        when :source
          SourceNode.new(name, content, writable)
        when :framework
          FrameworkNode.new(name, content, writable)
        when :resource
          ResourceNode.new(name, content, writable)
        when :group
          GroupNode.new(name, content, writable)
        else
          MpaasNode.new(name, content, writable)
        end
      end
    end
  end
end
