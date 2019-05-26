# frozen_string_literal: true

# template.rb
# MpaasKit
#
# Created by quinn on 2019-01-09.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 模版基类
  #
  class BaseTemplate
    include BasicInfo::Mixin

    # 初始化
    #
    # @param type 模版类型（:project/:app/:header/:category/:pch）
    # @param **ext_param 各子类的扩展参数
    #
    def initialize(type, **ext_param)
      @type = type.to_s
      @name = @type + '-template'
      parse_ext_param(ext_param)
      setup_working_dir if exist?
    end

    # 编辑模版
    # 抽象方法，子类实现
    #
    def edit; end

    # 保存模版
    # 抽象方法，子类实现
    #
    # @param _dest_path 保存的目的路径
    #
    def save(_dest_path = nil); end

    # 关闭模版
    # 操作完成或异常时必须关闭模版
    # 
    # e.g. begin
    #        template = BaseTemplate.new
    #        template.edit
    #        template.save
    #      ensure
    #        template.close
    #
    def close
      UILogger.debug "关闭模版: #{@name}/#{root_name}"
      clean_working_dir
    end

    # 模版保存后的产物（一般为一系列文件名）
    # 抽象方法，子类实现
    #
    # @return [Array] 产物数组
    #
    def products
      []
    end

    # 模版保存的位置
    # 抽象方法，子类实现
    #
    # @return [Pathname] 路径
    #
    def destination
      nil
    end

    # 模版根目录名称
    # 抽象方法，子类实现
    # 
    # @return [String]
    #
    def root_name
      ''
    end

    # 模版是否存在
    # 
    # @return [Bool]
    #
    def exist?
      File.exist?(preserved_uri + root_name)
    end

    protected

    # 通用替换的标签名
    GENERAL_LABEL_NAME = {
      :prototype => 'PROTOTYPE',     # 工程名
      :prefix => '$_PREFIX_$',       # 类名前缀
      :owner => 'PROJECT_OWNER',     # 作者
      :org => 'ORGANIZATION_NAME',   # 公司名
      :date => 'TODAYS_DATE',        # 日期
      :year => 'TODAYS_YEAR',        # 年份
      :target => 'TARGETNAME'        # target 名
    }.freeze

    # 替换文件内容标签
    #
    # @param file_pattern [String] 文件模版
    #
    def replace_file_content_labels(file_pattern, extend: {}, remove: [])
      UILogger.debug '替换文件内容标签'
      label_replacements = basic_label_replacements.merge(extend).delete_if do |k, _|
        remove.include?(k)
      end
      # 全局替换文件内容标签
      FileProcessor.global_replace_file_content!(label_replacements, file_pattern)
    end

    # 模版保存的路径
    # 默认为 mpaas-template/resources/xxx-template
    #
    # e.g. mpaas-template/resources/project-template
    #      mpaas-template/resources/app-template
    #
    def preserved_uri
      @preserved_uri ||= LocalPath.resource_dir + "#{@type}-template"
    end

    # 解析扩展参数
    # 抽象方法，子类实现.
    #
    # @param _ext_param 子类解析的扩展参数
    #
    def parse_ext_param(_ext_param); end

    # 临时工作区目录
    #
    def working_dir
      @working_dir ||= Pathname.new(Dir.mktmpdir)
    end

    # 建立临时工作区
    #
    def setup_working_dir
      FileUtils.cp_r(preserved_uri + root_name, working_dir)
    end

    # 清除工作区
    #
    def clean_working_dir
      safe_rm(working_dir)
    end

    private

    # 文件内容基础标签替换字典
    #
    # @return [Hash]
    #
    def basic_label_replacements
      {
        GENERAL_LABEL_NAME[:prototype] => basic_info.project_name,
        GENERAL_LABEL_NAME[:owner] => SystemInfo.user_name,
        GENERAL_LABEL_NAME[:org] => basic_info.organization,
        GENERAL_LABEL_NAME[:date] => Time.now.strftime('%Y/%m/%d'),
        GENERAL_LABEL_NAME[:year] => Time.now.year,
        GENERAL_LABEL_NAME[:prefix] => basic_info.class_prefix,
        GENERAL_LABEL_NAME[:target] => basic_info.active_target
      }
    end

    # 安全删除目录
    #
    def safe_rm(dir)
      FileUtils.remove_entry(dir) if Dir.exist?(dir)
    end
  end
end