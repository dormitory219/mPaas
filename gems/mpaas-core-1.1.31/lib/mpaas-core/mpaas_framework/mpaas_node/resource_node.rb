# frozen_string_literal: true

# resource_node.rb
# MpaasKit
#
# Created by quinn on 2019-01-12.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 资源节点
  # .bundle 文件、.jpg 文件等
  # 需要操作 build phases 的 Resources 阶段
  #
  class ResourceNode < MpaasNode
    def write(project_src_root)
      dest_path = project_src_root + path
      if content_string
        # 需要写入文件
        File.open(dest_path, 'wb') { |f| f.write(content_string) }
      elsif content_location
        # bundle 等资源直接从来源 copy
        FileUtils.cp_r(content_location, dest_path)
      end
    end

    def update(project_src_root)
      dest_path = project_src_root + path
      # 先删除旧资源
      FileUtils.remove_entry(dest_path) if dest_path.exist?
      # 写入新资源
      if update_content_string
        # 需要写入文件
        File.open(dest_path, 'wb') { |f| f.write(update_content_string) }
      elsif update_content_location
        # bundle 等资源直接从来源 copy
        FileUtils.cp_r(update_content_location, dest_path)
      end
    end

    def build_phase_name
      XcodeHelper::RESOURCES
    end
  end
end
