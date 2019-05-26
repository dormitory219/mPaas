# frozen_string_literal: true

# category_template.rb
# MpaasKit
#
# Created by quinn on 2019-01-10.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 分类文件模版
  #
  class CategoryTemplate < BaseTemplate
    def parse_ext_param(ext_param)
      @category_dir = ext_param.fetch(:dir)
      @file_type = ext_param.fetch(:type)
      @target = ext_param.fetch(:target) || basic_info.active_target
    end

    def root_name
      @category_dir
    end

    def edit
      UILogger.debug "编辑模版: #{@name}/#{root_name}/#{@save_name}"
      # 全局替换标签
      replace_file_content_labels(template_category_dir.to_s + '/**',
                                  :extend => { CATEGORY_NAME => escape_target_name },
                                  :remove => [GENERAL_LABEL_NAME[:prefix]])
      # 插入内容变量
      replace_content_variables
      # 重命名
      rename_file
    end

    def save(dest_path = nil)
      UILogger.debug "保存模版: #{@name}/#{root_name}/#{File.basename(dest_path)}"
      # 找到编辑的文件并保存，分别保存各自的分类文件
      editing_file = template_category_dir + File.basename(dest_path)
      FileUtils.mv(editing_file, dest_path)
    end

    def products
      # .h/.m
      [save_name]
    end

    private

    # 分类名，需要替换成无特殊符号
    CATEGORY_NAME = 'CATEGORYNAME'

    # 分类模版变量
    CATEGORY_VAR = {
      :rpc_gw       => '${RPC_GW}',       # rpc 网关
      :app_key      => '${APP_KEY}',      # app key
      :app_id       => '${APP_ID}',       # app id
      :log_gw       => '${LOG_GW}',       # 日志网关
      :workspace_id => '${WORKSPACE_ID}', # workspace id
      :sync_server  => '${SYNC_SERVER}',  # sync 网关
      :sync_port    => '${SYNC_PORT}'     # sync 端口
    }.freeze

    # 替换文件变量
    #
    def replace_content_variables
      UILogger.info '插入文件变量'
      app_info = basic_info.app_info
      var_replacements = {
        CATEGORY_VAR[:rpc_gw] => app_info[Constants::CONFIG_RPC_GW_KEY],
        CATEGORY_VAR[:app_key] => app_info[Constants::CONFIG_APP_KEY_KEY],
        CATEGORY_VAR[:app_id] => app_info[Constants::CONFIG_APP_ID_KEY],
        CATEGORY_VAR[:log_gw] => app_info[Constants::CONFIG_LOG_GW_KEY],
        CATEGORY_VAR[:workspace_id] => app_info[Constants::CONFIG_WORKSPACE_ID_KEY],
        CATEGORY_VAR[:sync_server] => app_info[Constants::CONFIG_SYNC_SERVER_KEY],
        CATEGORY_VAR[:sync_port] => app_info[Constants::CONFIG_SYNC_PORT_KEY]
      }
      editing_files.each do |editing_file|
        FileProcessor.insert_content_variables!(var_replacements, editing_file)
      end
    end

    # 重命名文件
    #
    def rename_file
      UILogger.debug '重命名文件'
      label_replacements = { GENERAL_LABEL_NAME[:target] => @target }
      FileProcessor.rename_file!(label_replacements, editing_files)
    end

    # 保存的文件名
    #
    # @return [String]
    #
    def save_name
      # 选取保存的文件名，对应类型的文件，.h/.m
      @save_name ||= File.basename(editing_files.find { |p| p.extname == @file_type })
                         .gsub(GENERAL_LABEL_NAME[:target], @target)
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

    # 编辑的文件
    #
    # @return [Array<Pathname>]
    #         所有分类文件的路径数组
    #
    def editing_files
      @editing_files ||= (Dir.entries(template_category_dir) - %w[. ..]).map do |entry|
        template_category_dir + entry
      end
    end

    # 模版模块目录
    #
    def template_category_dir
      @template_category_dir ||= working_dir + root_name
    end
  end
end
