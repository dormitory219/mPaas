# frozen_string_literal: true

# header_template.rb
# MpaasKit
#
# Created by quinn on 2019-01-10.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 头文件模版
  #
  class HeaderTemplate < BaseTemplate
    def parse_ext_param(ext_param)
      @headers_content = ext_param.fetch(:headers, [])
      @target = ext_param.fetch(:target) || basic_info.active_target
      @save_name = "#{@target}-mPaaS-Headers.h"
    end

    def root_name
      HEADER_TEMPLATE_NAME
    end

    def edit
      UILogger.debug "编辑模版: #{@name}/#{root_name}"
      # 替换文件内容标签
      replace_file_content_labels(editing_file,
                                  :extend => { MACRO_NAME => escape_target_name })
      # 插入内容变量
      replace_content_variables
      # 重命名
      rename_file
    end

    def save(dest_path = nil)
      UILogger.debug "保存模版: #{@name}/#{root_name}"
      # 移动到目标目录下
      FileUtils.mv(working_dir + @save_name, dest_path)
    end

    def products
      [@save_name]
    end

    private

    # 头文件宏名称
    MACRO_NAME = 'ESCAPENAME'
    # 头文件模版名称
    HEADER_TEMPLATE_NAME = 'TARGETNAME-mPaaS-Headers.h'
    # 头文件内容变量
    HEADER_CONTENT_VAR = '${IMPORT_HEADERS}'
    # 系统基础头文件
    SYS_BASIC_HEADERS = %w[<Foundation/Foundation.h> <UIKit/UIKit.h>].freeze

    # 替换文件变量
    #
    def replace_content_variables
      UILogger.debug '插入文件变量'
      content = (SYS_BASIC_HEADERS + @headers_content).map { |header| '#import ' + header }
      var_replacements = { HEADER_CONTENT_VAR => content.join("\n") }
      FileProcessor.insert_content_variables!(var_replacements, editing_file)
    end

    # 重命名文件
    #
    def rename_file
      UILogger.debug '重命名文件'
      label_replacements = { GENERAL_LABEL_NAME[:target] => @target }
      FileProcessor.rename_file!(label_replacements, editing_file)
    end

    # 将target名称变为标准的标识符
    # 字母下划线开头的，字母数字下划线组合
    #
    # @return [String]
    #
    def escape_target_name
      valid_name = @target.gsub(/[^a-zA-Z0-9_]/, '')
      # 防止首字母为数字
      valid_name = '_' + valid_name if (0..9).map(&:to_s).include?(valid_name[0])
      valid_name
    end

    # 编辑的头文件
    #
    # @return [Pathname]
    #
    def editing_file
      @editing_file ||= (working_dir + root_name).to_s
    end
  end
end
