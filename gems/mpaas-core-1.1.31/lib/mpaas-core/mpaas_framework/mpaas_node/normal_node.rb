# frozen_string_literal: true

# normal_node.rb
# MpaasKit
#
# Created by quinn on 2019-01-12.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 普通文件节点
  # 普通文件、.h 文件、.pch 文件等
  # 不需要操作 build phase
  #
  class NormalNode < MpaasNode
    def write(project_src_root)
      dest_path = project_src_root + path
      if content_string
        # 需要写入文件
        File.open(dest_path, 'w') { |f| f.write(content_string) }
      elsif content_json_obj
        # 需要写入文件
        File.open(dest_path, 'w') { |f| f.write(JSON.pretty_generate(content_json_obj)) }
      elsif content_template
        # .h 文件等需要编辑模版
        content_template.edit
        content_template.save(dest_path)
      end
    end

    def update(project_src_root)
      dest_path = project_src_root + path
      # 先删除原文件
      FileUtils.remove_entry(dest_path) if dest_path.exist?
      # 写入新的内容
      if update_content_string
        # 需要写入文件
        File.open(dest_path, 'w') { |f| f.write(update_content_string) }
      elsif update_content_json_obj
        # 需要写入文件
        File.open(dest_path, 'w') { |f| f.write(JSON.pretty_generate(update_content_json_obj)) }
      elsif update_content_template
        # .h 文件等需要编辑模版
        update_content_template.edit
        update_content_template.save(dest_path)
      end
    end

    def add_reference(xcodeproj_path)
      if content_template.nil? || content_template.destination.nil?
        super(xcodeproj_path)
      else
        # 原始引用和 mpaas 目录下引用都添加（pch 文件）
        full_path = content_template.destination + name
        file_ref = XcodeHelper.find_file_reference(xcodeproj_path, full_path)
        XcodeHelper.add_file_reference(xcodeproj_path, full_path) if file_ref.nil?
        group_path = xcodeproj_path.parent + parent.path
        # 组下面引用不存在才添加
        return if XcodeHelper.file_reference_exist?(xcodeproj_path, full_path, group_path)
        XcodeHelper.add_file_reference(xcodeproj_path, full_path, group_path)
      end
    end

    def reference_exist?(xcodeproj_path)
      if content_template.nil? || content_template.destination.nil?
        super(xcodeproj_path)
      else
        full_path = content_template.destination + name
        group_path = xcodeproj_path.parent + parent.path
        # 原始引用和 mpaas 目录下的引用都存在(pch 文件)
        XcodeHelper.file_reference_exist?(xcodeproj_path, full_path) &&
          XcodeHelper.file_reference_exist?(xcodeproj_path, full_path, group_path)
      end
    end

    def build_phase_name
      # 将 meta.config 加入 build phase
      XcodeHelper::BuildPhaseName::RESOURCES if @name == Constants::APP_INFO_FILE_NAME
    end
  end
end
