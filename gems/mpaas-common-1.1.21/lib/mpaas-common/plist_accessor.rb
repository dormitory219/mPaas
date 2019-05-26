# frozen_string_literal: true

# plist_accessor.rb
# MpaasKit
#
# Created by quinn on 2019-01-09.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # plist 工具
  #
  class PlistAccessor
    # TODO: data, date 数据类型暂不支持
    class << self
      # 添加 plist 文件中的某项
      # 直接修改原文件
      #
      # @param [String] plist_path plist 文件
      #                 需要保证 plist文件是非 binary 模式
      # @param [Array] entry  添加项路径数组，可以指定数组下标
      #                e.g. ['Key1', 'Value1', 2]
      # @param value 添加的值
      #
      def add_entry!(plist_path, entry, value, override = true)
        UILogger.debug "添加 plist 项: #{entry.join(':')} #{plist_path}"
        modify_plist(plist_path) do |plist_hash|
          key = entry.pop
          node = find_node_by_entry(plist_hash, entry)
          return if node.nil?

          if node.is_a?(Array)
            # 数组指定位置插入
            node.insert(key, value)
          elsif node.is_a?(Hash)
            raise "该字段已经存在: #{entry.join(':')}" if node.key?(key) && !override
            # 字典插入
            node[key] = value
          else
            raise "该字段已经存在: #{entry.join(':')}"
          end
        end
      end

      # 删除 plist 文件中的某项
      # 直接修改原文件
      #
      # @param [String] plist_path plist 文件
      #        需要保证 plist文件是非 binary 模式
      # @param [Array] entry 删除项路径数组，可以指定数组下标
      #        e.g. ['Key1', 'Value1', 2]
      #
      def remove_entry!(plist_path, entry)
        UILogger.debug "删除 plist 项: #{entry.join(':')} #{plist_path}"
        modify_plist(plist_path) do |plist_hash|
          key = entry.pop
          node = find_node_by_entry(plist_hash, entry)
          return if node.nil?
          # 从数组/字典中删除字段
          node.delete_at(key) if node.is_a?(Array)
          node.delete(key) if node.is_a?(Hash)
        end
      end

      # 修改 plist 文件中的某项
      # 直接修改原文件
      #
      # @param [String] plist_path plist 文件
      #        需要保证 plist文件是非 binary 模式
      # @param [Array] entry 修改项路径数组，可以指定数组下标
      #        e.g. ['Key1', 'Value1', 2]
      # @param value 修改的值
      #
      def update_entry!(plist_path, entry, value)
        UILogger.debug "修改 plist 项: #{entry.join(':')} #{plist_path}"
        modify_plist(plist_path) do |plist_hash|
          key = entry.pop
          node = find_node_by_entry(plist_hash, entry)
          return if node.nil?
          # 更新值
          node[key] = value
        end
      end

      # 获取 plist 文件中某项的值
      #
      # @param [String] plist_path plist 文件
      #                 需要保证 plist文件是非 binary 模式
      # @param [Array] entry 修改项路径数组，可以指定数组下标
      #                e.g. ['Key1', 'Value1', 2]
      # @return [String, Array, Hash, Integer, Bool, nil] 解析结果
      #
      def fetch_entry(plist_path, entry)
        UILogger.debug "查找 plist 项: #{entry.join(':')} #{plist_path}"
        plist_hash = Xcodeproj::Plist.read_from_path(plist_path)
        find_node_by_entry(plist_hash, entry)
      end

      # plist 中对应项是否存在
      #
      # @param [String] plist_path plist 文件
      #                 需要保证 plist文件是非 binary 模式
      # @param [Array] entry 修改项路径数组，可以指定数组下标
      #                e.g. ['Key1', 'Value1', 2]
      # @return [Bool]
      #
      def entry_exists?(plist_path, entry)
        plist_hash = Xcodeproj::Plist.read_from_path(plist_path)
        !find_node_by_entry(plist_hash, entry).nil?
      end

      private

      # 读取 plist 文件内容
      #
      # @param path [String] 文件路径
      # @param binmode [Bool] 是否二进制模式
      # @return [Hash] 内容字典
      #
      def read_from_path(path, binmode = false)
        path = path.to_s
        raise "The plist file at path `#{path}` doesn't exist." unless File.exist?(path)
        # 根据是否为二进制模式，选择不同的读文件方法
        contents = binmode ? File.binread(path) : File.read(path)
        raise "The file `#{path}` is in a merge conflict." if Xcodeproj::Plist.file_in_conflict?(contents)
        # 转换字典
        case Nanaimo::Reader.plist_type(contents)
        when :xml, :binary
          CFPropertyList.native_types(CFPropertyList::List.new(:data => contents).value)
        else
          Nanaimo::Reader.new(contents).parse!.as_ruby
        end
      end

      # 修改 plist
      #
      # @param plist_path plist 文件路径
      # @param &block 修改回调，block 内部修改 plist_hash
      #
      def modify_plist(plist_path)
        plist_hash = Xcodeproj::Plist.read_from_path(plist_path)
        yield(plist_hash) if block_given?
        Xcodeproj::Plist.write_to_path(plist_hash, plist_path)
      end

      # 根据路径，找到节点
      #
      # @param root plist 的根节点
      # @param entry [Array] 修改项路径数组，可以指定数组下标
      #              e.g. ['Key1', 'Value1', 2]
      # @return [Hash, Array, String, Bool, Integer, nil]
      #         对应节点，无法定位节点，返回 nil
      #
      def find_node_by_entry(root, entry)
        current_node = root
        Array(entry).each { |key_or_idx| current_node = current_node[key_or_idx] }
        current_node
      rescue StandardError
        UILogger.warning "找不到该字段: #{entry.join(':')}"
        current_node = nil
      ensure
        current_node
      end
    end
  end
end
