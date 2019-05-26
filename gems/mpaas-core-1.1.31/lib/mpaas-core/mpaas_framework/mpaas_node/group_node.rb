# frozen_string_literal: true

# group_node.rb
# MpaasKit
#
# Created by quinn on 2019-01-12.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 枝节点
  #
  class GroupNode < MpaasNode
    def leaf?
      false
    end

    def write(project_src_root)
      # 创建自身目录
      FileUtils.mkdir_p(project_src_root + path)
    end

    def remove(project_src_root)
      # 整个节点可以删除，直接删除目录
      FileUtils.remove_entry(project_src_root + path) if (project_src_root + path).exist?
    end

    def remove_flag
      return false if @children.empty?
      # 任意一个子节点删除标记为 false 则不可删除
      each_child do |child_node|
        return false unless child_node.remove_flag
      end
      true
    end

    def add_reference(xcodeproj_path)
      return if reference_exist?(xcodeproj_path)
      XcodeHelper.add_group_reference(xcodeproj_path, xcodeproj_path.parent + path)
    end

    def remove_reference(xcodeproj_path)
      XcodeHelper.remove_group_reference(xcodeproj_path, xcodeproj_path.parent + path)
    end

    def reference_exist?(xcodeproj_path)
      !XcodeHelper.find_group_reference(xcodeproj_path, xcodeproj_path.parent + path).nil?
    end
  end
end
