# frozen_string_literal: true

# action_del.rb
# MpaasKit
#
# Created by quinn on 2019-01-12.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class MpaasFramework
    class NodeGenerator
      # 删除操作
      #
      class GeneratorActionDel < GeneratorAction
        def start(parent_node, node_name, _node_content, _node_type)
          node = parent_node.find(node_name)
          raise "待删除节点不存在: #{name}" if node.nil?
          # 标记删除状态
          node.mark_remove_flag
          node
        end
      end
    end
  end
end
