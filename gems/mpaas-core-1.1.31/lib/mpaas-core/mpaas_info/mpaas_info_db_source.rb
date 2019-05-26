# frozen_string_literal: true

# mpaas_info_db_source.rb
# workspace
#
# Created by quinn on 2019-03-21.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # mpaas 信息内存数据库，各类数据源处理
  #
  class MpaasInfoDB
    private

    # 解析头文件
    #
    # @param condition [Proc] 查找数据条件
    # @return [Array<String, HeaderTemplate, Symbol>, nil] 数组为三个元素
    #         第一个为头文件的名称，第二个为模版实例，第三个为操作类型
    #         无集成模块，返回 nil
    # e.g. [xx-mPaaS-Headers.h, template, :add]
    #
    def header(condition)
      # 选取编辑的模块
      records = all(condition)
      # 无模块，直接返回空
      return nil if records.empty?
      # 如果所有模块都是新增，那么就是新增操作，否则为更新操作，如果全部为删除则为删除操作
      operation = records.reject { |record| record.operation_type == :add }.empty? ? :add : :alt
      operation = :del if records.reject { |record| record.operation_type == :del }.empty?
      # 提取所有非删除的头文件
      headers_content = records.reject { |record| record.operation_type == :del }.map do |record|
        record.module_obj.header_files
      end.flatten.uniq
      # 生成模版
      template = TemplatesFactory.load_template(:header,
                                                :headers => headers_content, :target => records.first.target)
      [template.products.shift, template, operation]
    end

    # 解析 pch 文件
    #
    # @param condition [Proc] 查找数据条件
    # @return [Array<String, Symbol>,nil] 数组为两个元素
    #         第一个为头文件的名称，第二个为操作类型
    #         无集成模块，返回nil
    # e.g. [xx-mPaaS-Headers.h, :add]
    #
    def pch(condition)
      header_file, _, op = header(condition)
      [header_file, op] unless header_file.nil?
    end

    # 分类文件及模版
    #
    # @param condition [Proc] 查找数据条件
    # @return [Array<Array<String, String, CategoryTemplate, Symbol>>]
    #         内层数组为四个元素，第一个为所在的模块名，第二个为分类文件的名称，第三个为模版实例
    #         第四个为操作类型
    # e.g. [[APMobileFramework, APMobileFramework+demo, template, :add], ...]
    #
    def categories(condition)
      records = all(condition)
      pairs = records.flat_map do |record|
        category_dir_list = record.module_obj.category_dir_list
        # 不需要分类文件
        next if category_dir_list.nil?
        category_dir_list.flat_map do |dir|
          # 一个目录，返回.h和.m两个数据
          h_pair = generate_category_pair(record, '.h', dir)
          m_pair = generate_category_pair(record, '.m', dir)
          [h_pair, m_pair].compact
        end.compact
      end.compact
      h_pairs = pairs.select { |_, name, _, _| name.end_with?('.h') }
      m_pairs = pairs.select { |_, name, _, _| name.end_with?('.m') }
      uniq_pair(h_pairs).zip(uniq_pair(m_pairs)).flatten(1)
    end

    # 生成分类文件数据对
    #
    # @param [String] type #
    # @param [ModuleRecord] record
    #        内层数组为四个元素，第一个为所在的模块名，第二个为分类文件的名称，第三个为模版实例
    #        第四个为操作类型
    #
    # @return [Array]
    #
    def generate_category_pair(record, type, category_dir)
      category_template = TemplatesFactory.load_template(:category,
                                                         :dir => category_dir,
                                                         :type => type,
                                                         :target => record.target)
      return nil unless category_template.exist?
      # 屏蔽更新
      op = record.operation_type == :alt ? :none : record.operation_type
      [category_dir, category_template.products.shift, category_template, op]
    end

    # 模块 framework 名称及位置路径
    #
    # @param condition [Proc] 查找数据条件
    # @return [Array<Array<String, String, Symbol>>] 内层数组为三个元素
    #         第一个为 .framework 文件的名称，第二个为 .framework 文件本地路径，第三个为操作类型
    # e.g. [[xxx.framework, /Users/Shared/.mpaaskit_sdk/xxx, :add], ...]
    #
    def mpaas_frameworks(condition)
      records = all(condition)
      uniq_pair(records.map do |record|
        module_obj = record.module_obj
        frameworks = module_obj.frameworks
        count = frameworks.count
        pairs = frameworks.zip(module_obj.framework_locations, [record.operation_type] * count)
        pairs.each { |pair| pair[2] = :del if !@conflict_frameworks.nil? && @conflict_frameworks.include?(pair.first) }
      end.compact.flatten(1))
    end

    # 模块资源文件名称及位置路径
    #
    # @param condition [Proc] 查找数据条件
    # @return [Array<Array<String, String, Symbol>>] 内层数组为三个元素
    #         第一个为资源文件的名称，第二个为资源文件本地路径，第三个为操作类型
    # e.g. [[xxx.bundle, /Users/Shared/.mpaaskit_sdk/xxx, :add], ...]
    #
    def mpaas_resources(condition)
      records = all(condition)
      uniq_pair(records.map do |record|
        module_obj = record.module_obj
        resources = module_obj.resources
        count = resources.count
        pairs = resources.zip(module_obj.resource_locations, [record.operation_type] * count)
        pairs.each { |pair| pair[2] = :del if !@conflict_resources.nil? && @conflict_resources.include?(pair.first) }
      end.compact.flatten(1))
    end

    # 系统 framework 文件名
    #
    # @param condition [Proc] 查找数据条件
    # @return [Array<String, Symbol>] 内层数组为两个元素
    #         第一个为系统 framework 库文件名，第二个为操作类型
    #
    def sys_frameworks(condition)
      uniq_pair(all(condition).flat_map do |record|
        record.module_obj.system_frameworks.map { |name| [name, record.operation_type] }
      end)
    end

    # 系统 lib 文件名
    #
    # @param condition [Proc] 查找数据条件
    # @return [Array<String, Symbol>] 内层数组为两个元素
    #         第一个为系统 lib 库文件名，第二个为操作类型
    #
    def sys_libraries(condition)
      uniq_pair(all(condition).flat_map do |record|
        record.module_obj.system_libraries.map { |name| [name, record.operation_type] }
      end)
    end

    # 是否包含该 target 的对应模块
    #
    # @param name [String] 模块名称
    # @param target [String] target 名称
    # @return [Bool]
    #
    def include?(name, target)
      !all(->(record) { record.target == target && record.name == name }).empty?
    end

    # 对不同操作去重
    #
    # @param [Array] pairs 第一个元素是name，最后一个元素是op
    # @return [Array] 去重后的结果
    #
    def uniq_pair(pairs)
      add_list = [] # 添加的库
      remove_list = [] # 删除的库
      other_list = [] # 不处理的库
      pairs.uniq { |p| [p.first, p.last] }.each do |pair|
        if pair.last == :add
          add_list << pair
        elsif pair.last == :del
          remove_list << pair
        else
          other_list << pair
        end
      end
      # none+* => none, add+del => add
      # del标记的，如果出现在add和none中，就都去除
      remove_list.reject! do |pair|
        add_list.map(&:first).include?(pair.first) || other_list.map(&:first).include?(pair.first)
      end
      # add操作的，如果出现在none中，就去除
      add_list.reject! do |pair|
        other_list.map(&:first).include?(pair.first)
      end
      other_list + add_list + remove_list
    end
  end
end
