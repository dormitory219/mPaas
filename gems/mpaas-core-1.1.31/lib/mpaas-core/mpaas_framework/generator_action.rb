# frozen_string_literal: true

# generator_action.rb
# MpaasKit
#
# Created by quinn on 2019-01-12.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class MpaasFramework
    class NodeGenerator
      # 节点生成的动作抽象类
      #
      class GeneratorAction
        require_relative 'action/action_add'
        require_relative 'action/action_del'
        require_relative 'action/action_alt'

        include BasicInfo::Mixin

        # 执行操作，对节点本地化的操作进行标记（增删改）
        # 直接修改节点内容
        #
        # @param parent_node [MpaasNode] 父节点
        # @param node_name 当前操作的节点名称
        # @param node_content 当前操作的节点内容
        # @param node_type 当前操作的节点类型
        # @param operation [Symbol] 当前执行的操作类型（:add/:del/:alt)
        # @return [MpaasNode] 操作的节点
        #
        def self.operate!(parent_node, node_name, node_content, node_type, operation)
          return nil if operation.nil? || operation == :none
          # 创建对应的action
          action = Object.const_get(to_s.concat(operation.to_s.capitalize)).new
          action.start(parent_node, node_name, node_content, node_type)
        end

        # 存储节点操作类型，对节点集成的操作进行标记（增删改）
        #
        # @param [MpaasNode] parent_node
        # @param [String] node_name
        # @param [String] target
        # @param [Symbol] operation
        #
        def self.store!(parent_node, node_name, target, operation)
          node = parent_node.find(node_name)
          node.store_integration_op(target, operation)
        end

        # 执行操作
        # 抽象方法，子类实现
        #
        # @param _parent_node [MpaasNode] 父节点
        # @param _node_name 当前操作的节点名称
        # @param _node_content 当前操作的节点内容
        # @param _node_type 当前操作的节点类型
        # @return [MpaasNode] 操作的节点
        #
        def start(_parent_node, _node_name, _node_content, _node_type); end
      end
    end
  end
end
