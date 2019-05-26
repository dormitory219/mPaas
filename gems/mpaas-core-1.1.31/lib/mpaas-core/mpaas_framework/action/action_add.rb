# frozen_string_literal: true

# action_add.rb
# MpaasKit
#
# Created by quinn on 2019-01-12.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class MpaasFramework
    class NodeGenerator
      # 添加操作
      #
      class GeneratorActionAdd < GeneratorAction
        include BasicInfo::Mixin

        def start(parent_node, node_name, node_content, node_type)
          node = parent_node.find(node_name)
          if node.nil?
            # 新增节点
            # framework 节点的写入条件取决于是否 copy，其它节点无限制
            writable = node_type == :framework ? basic_info.copy_mode : true
            node = NodeFactory.create(node_type, node_name, node_content, writable)
            parent_node.append_child(node)
          end
          node
        end
      end
    end
  end
end
