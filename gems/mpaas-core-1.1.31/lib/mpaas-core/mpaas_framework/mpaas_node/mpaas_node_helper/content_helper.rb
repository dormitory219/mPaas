# frozen_string_literal: true

# content_helper.rb
# MpaasKit
#
# Created by quinn on 2019-01-12.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 提供节点获取内容的方法
  #
  class MpaasNode
    # 内容来源路径
    #
    # @return [Pathname]
    #
    def content_location
      leaf? && !@content.nil? && @content.is_a?(Pathname) ? @content : nil
    end

    # 内容模版
    #
    # @return [BaseTemplate]
    #
    def content_template
      leaf? && !@content.nil? && @content.is_a?(BaseTemplate) ? @content : nil
    end

    # 内容字符串
    #
    # @return [String]
    #
    def content_string
      leaf? && !@content.nil? && @content.is_a?(String) ? @content : nil
    end

    # 内容 json 对象
    #
    # @return [Hash]
    #
    def content_json_obj
      leaf? && !@content.nil? && @content.is_a?(Hash) ? @content : nil
    end

    # 更新内容来源路径
    #
    # @return [Pathname]
    #
    def update_content_location
      leaf? && !@update_content.nil? && @update_content.is_a?(Pathname) ? @update_content : nil
    end

    # 内容模版
    #
    # @return [BaseTemplate]
    #
    def update_content_template
      leaf? && !@update_content.nil? && @update_content.is_a?(BaseTemplate) ? @update_content : nil
    end

    # 内容字符串
    #
    # @return [String]
    #
    def update_content_string
      leaf? && !@update_content.nil? && @update_content.is_a?(String) ? @update_content : nil
    end

    # 内容 json 对象
    #
    # @return [Hash]
    #
    def update_content_json_obj
      leaf? && !@update_content.nil? && @update_content.is_a?(Hash) ? @update_content : nil
    end
  end
end
