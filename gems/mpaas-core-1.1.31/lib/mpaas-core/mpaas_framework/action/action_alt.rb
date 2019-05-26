# frozen_string_literal: true

# action_alt.rb
# MpaasKit
#
# Created by quinn on 2019-01-12.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class MpaasFramework
    class NodeGenerator
      # 更新修改操作
      #
      class GeneratorActionAlt < GeneratorAction
        def start(parent_node, node_name, node_content, _node_type)
          node = parent_node.find(node_name)
          raise "待更新节点不存在: #{node_name}" if node.nil?
          # 更新节点内容
          node.update_content = node_content
          node
        end
      end
    end
  end
end
