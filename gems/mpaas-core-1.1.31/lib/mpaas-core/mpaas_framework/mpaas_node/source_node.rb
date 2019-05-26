# frozen_string_literal: true

# source_node.rb
# MpaasKit
#
# Created by quinn on 2019-01-12.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 源文件节点
  # .m 文件、.cpp 文件等
  # 需要操作 build phases 的 Sources 阶段
  #
  class SourceNode < MpaasNode
    def write(project_src_root)
      return unless content_template
      # 编辑模版
      content_template.edit
      content_template.save(project_src_root + path)
    end

    def update(project_src_root)
      dest_path = project_src_root + path
      FileUtils.remove_entry(dest_path) if dest_path.exist?
      # 编辑模版
      update_content_template.edit
      update_content_template.save(dest_path)
    end

    def build_phase_name
      XcodeHelper::SOURCES
    end
  end
end
