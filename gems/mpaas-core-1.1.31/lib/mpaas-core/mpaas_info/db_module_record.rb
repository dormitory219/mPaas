# frozen_string_literal: true

# db_module_record.rb
# MpaasKit
#
# Created by quinn on 2019-01-11.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 数据库的模块记录
  #
  class DBModuleRecord
    # 初始化
    #
    # @param name 模块名
    # @param target target 名称
    # @param from_obj [ModuleObject] 原始模块对象
    # @param to_obj [ModuleObject] 更新模块对象
    #
    def initialize(name, target, from_obj = nil, to_obj = nil)
      @name = name
      @from = from_obj&.version
      @to = to_obj&.version
      @from_obj = from_obj
      @to_obj = to_obj
      @target = target
    end

    attr_reader :name, :target

    # 模块更新
    #
    # @param to_obj [ModuleObject] 更新模块对象
    #
    def update_to(to_obj)
      @to = to_obj&.version
      @to_obj = to_obj
    end

    # 该记录的模块对象
    #
    # @return [ModuleObject]
    #
    def module_obj
      return @from_obj if removed?
      return @to_obj if added? || update?
      @from_obj
    end

    # 该记录的操作类型
    #
    # @return [Symbol]
    #
    def operation_type
      return :del if removed?
      return :add if added?
      return :alt if update?
      :none
    end

    # 是否是删除模块
    #
    # @return [Bool]
    #
    def removed?
      # from x to nil 表示删除
      !@from_obj.nil? && @to_obj.nil?
    end

    # 是否是新增模块
    #
    # @return [Bool]
    #
    def added?
      # from nil to x 表示新增
      @from_obj.nil? && !@to_obj.nil?
    end

    # 是否是更新模块
    #
    # @return [Bool]
    #
    def update?
      # from x to y 且 x != y 表示更新
      !@from_obj.nil? && !@to_obj.nil? && @from_obj.module_updated?(@to_obj)
    end
  end
end
