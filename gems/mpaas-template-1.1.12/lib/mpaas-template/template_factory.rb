# frozen_string_literal: true

# template_factory.rb
# MpaasKit
#
# Created by quinn on 2019-01-09.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 模版工厂类
  #
  module TemplatesFactory
    class << self
      # 读取对应类型的模版
      #
      # @param type 读取的模版类型（:project :app :header :category :pch :entitlement）
      #             :project 工程模版
      #             :app 应用 launcher 模版
      #             :header 头文件模版
      #             :category 分类文件模版
      #             :pch pch 文件模版
      #             :entitlement entitlement 模版
      # @param **ext_param 子类使用的扩展参数
      # @return [ProjectTemplate, AppTemplate, HeaderTemplate, CategoryTemplate, PchTemplate]
      #         模版实例具体的子类
      #
      def load_template(type, **ext_param)
        case type
        when :project # xcode 工程模版
          ProjectTemplate.new(type, **ext_param)
        when :app # 获取应用入口模版
          AppTemplate.new(type, **ext_param)
        when :header # 头文件模版
          HeaderTemplate.new(type, **ext_param)
        when :category # 分类文件模版
          CategoryTemplate.new(type, **ext_param)
        when :pch # pch 文件模版
          PchTemplate.new(type, **ext_param)
        when :entitlement
          EntitlementTemplate.new(type, **ext_param)
        end
      end
    end
  end
end