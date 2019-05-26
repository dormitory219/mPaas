# frozen_string_literal: true

# pch_template.rb
# MpaasKit
#
# Created by quinn on 2019-01-10.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # pch 模版
  #
  class PchTemplate < BaseTemplate
    def parse_ext_param(ext_param)
      # 是否为移除操作
      @remove_flag = ext_param.fetch(:remove, false)
      # 导入的 mpaas 头文件名称
      @header_file = ext_param.fetch(:header_file, '')
      # pch 文件路径 / 保存工程 pch 文件的目录
      @save_path = Pathname.new(ext_param.fetch(:project_pch, nil))
      if @save_path.extname == '.pch'
        UILogger.debug("已经存在 pch 文件: #{@save_path}")
        @save_name = @save_path.basename.to_s
        @save_path = @save_path.parent
      else
        # 保存 pch 文件名
        @save_name = "#{basic_info.project_name}-Prefix.pch"
      end
      @mode = parse_mode
      UILogger.debug "解析的 pch 模版 mode 为: #{@mode}"
    end

    def root_name
      PCH_TEMPLATE_NAME
    end

    def edit
      UILogger.debug "编辑模版: #{@name}/#{root_name}"
      action_hash = {
        EDITING_MODE_INSERT => :insert_mode,
        EDITING_MODE_APPEND => :append_mode,
        EDITING_MODE_NEW => :new_mode
      }
      method(action_hash[@mode]).call
    end

    def save(_dest_path = nil)
      UILogger.debug '保存模版'
      # 新建模式，拷贝模版到目录
      result_file = File.dirname(editing_file) + '/' + @save_name
      FileUtils.mv(result_file, @save_path) if @mode == EDITING_MODE_NEW
    end

    def products
      [@save_name]
    end

    def destination
      @save_path
    end

    private

    # pch 模版名称
    PCH_TEMPLATE_NAME = 'PROTOTYPE-Prefix.pch'
    # 内容起始标记
    PCH_BEGIN_MARK = '#ifndef Mpaas_Prefix_Header_pch'
    # 内容结束标记
    PCH_END_MARK = '#endif /* Mpaas_Prefix_Header_pch */'
    # pch 内容变量
    PCH_CONTENT_VAR = '${HEADER_FILES}'
    # 系统基础头文件
    SYS_BASIC_HEADERS = %w[<Foundation/Foundation.h> <UIKit/UIKit.h>].freeze

    # 插入模式
    EDITING_MODE_INSERT = :insert
    # 追加模式
    EDITING_MODE_APPEND = :append
    # 新建模式
    EDITING_MODE_NEW = :new

    # 解析编辑模式
    #
    # @return [Symbol] 编辑模式
    #
    def parse_mode
      if File.exist?(project_pch_file) && File.read(project_pch_file).match(/#import.+\n/)
        # 工程 pch 文件存在并且包含 import 内容
        EDITING_MODE_INSERT
      elsif File.exist?(project_pch_file)
        # 工程 pch 文件存在并且不包含 import 内容
        EDITING_MODE_APPEND
      else
        # 工程 pch 文件不存在
        EDITING_MODE_NEW
      end
    end

    # 插入模式
    #
    def insert_mode
      # 待插入的头文件
      content = SYS_BASIC_HEADERS + ["\"#{@header_file}\""]
      # 找出所有 import 的头文件
      existing_headers = File.read(project_pch_file).scan(%r{#import (["-<>\w\/.]+)\n}).flatten.uniq
      # 查找 mpaas header
      mpaas_header = existing_headers.find { |header| header.include?('mPaaS-Header') }
      if mpaas_header.nil?
        # 不存在，插入 header
        content.reject! { |header| existing_headers.include?(header) }
        content.map! { |header| '#import ' + header + "\n" }
        FileProcessor.insert_file!(project_pch_file, content.join('')) do |buffer|
          # 第一个 import 之前添加
          idx = buffer.index(/\n#import.+\n/)
          idx + 1 unless idx.nil?
        end
      else
        # 存在，替换 header 名称
        replacements = if @remove_flag # 删除
                         { "#import #{mpaas_header}" => '' }
                       else # 替换
                         { mpaas_header => "\"#{@header_file}\"" }
                       end
        FileProcessor.global_replace_file_content!(replacements, project_pch_file)
      end
    end

    # 追加模式
    #
    def append_mode
      # 插入模版变量
      replace_content_variables
      # 提取模版内容段
      content = FileProcessor.fetch_segment(editing_file, PCH_BEGIN_MARK, PCH_END_MARK)
      # 追加写入工程 pch 文件
      FileProcessor.append_content!(project_pch_file, content.join(''))
    end

    # 新建模式
    #
    def new_mode
      # 替换标签
      replace_file_content_labels(editing_file)
      # 插入变量内容
      replace_content_variables
      # 重命名文件
      rename_file
    end

    # 替换文件变量
    #
    def replace_content_variables
      UILogger.debug '插入文件变量'
      content = (SYS_BASIC_HEADERS + ["\"#{@header_file}\""]).map { |header| '#import ' + header + "\n" }
      var_replacements = { PCH_CONTENT_VAR => content.join('') }
      FileProcessor.insert_content_variables!(var_replacements, editing_file)
    end

    # 重命名文件
    #
    def rename_file
      UILogger.debug '重命名文件'
      label_replacements = { GENERAL_LABEL_NAME[:prototype] => basic_info.project_name }
      FileProcessor.rename_file!(label_replacements, editing_file)
    end

    # 编辑的文件
    #
    def editing_file
      @editing_file ||= (working_dir + root_name).to_s
    end

    # 工程的 pch 文件
    #
    def project_pch_file
      @project_pch_file ||= @save_path + @save_name
    end
  end
end
