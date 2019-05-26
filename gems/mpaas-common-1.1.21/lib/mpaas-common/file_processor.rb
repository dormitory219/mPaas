# frozen_string_literal: true

# file_processor.rb
# MpaasKit
#
# Created by quinn on 2019-01-09.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 文件转换工具
  #
  module FileProcessor
    class << self
      # 全局替换文件内容
      #
      # @param label_hash 标签字典 {搜索标签 => 替换内容}
      # @param path 搜索的目标路径，可以使用递归模式
      #
      def global_replace_file_content!(label_hash, path)
        buffer = ''
        Dir.glob(path).each do |name|
          # 如果是目录或文件不存在，则跳过
          next if File.directory?(name) || !File.exist?(name)

          UILogger.debug("替换标签文件: #{name}")
          buffer = File.read(name)
          label_hash.each do |label, replace|
            buffer = buffer.gsub(label.to_s, replace.to_s)
          end
          File.open(name, 'wb') { |file| file.puts buffer }
        end
      end
      alias insert_content_variables! global_replace_file_content!

      # 重命名文件，允许批量
      #
      # @param label_hash 文件名中的标签字典 {搜索标签 => 替换内容}
      # @param path 文件路径，可以数组
      #
      def rename_file!(label_hash, path)
        dest = ''
        [path].flatten.each do |file|
          next unless File.exist? file

          dest = File.basename(file)
          label_hash.each do |label, replace|
            dest = dest.gsub(label.to_s, replace.to_s)
          end
          UILogger.debug("重命名文件: #{file} -> #{dest} ")
          FileUtils.mv(file, File.dirname(file) + '/' + dest)
        end
      end

      # 向文件插入内容
      #
      # @param file_path 文件路径
      # @param content 插入内容字符串
      # @param &block 回调获取插入位置，返回文件内容 buffer
      #
      def insert_file!(file_path, content)
        return if !File.exist?(file_path) || content.empty? || !block_given?
        # 获取插入位置
        buffer = File.read(file_path)
        index = yield buffer
        return if index.nil?
        # 插入文件
        UILogger.debug "在文件 #{file_path} 内插入内容: #{content}"
        buffer.insert(index, content)
        File.open(file_path, 'wb') { |f| f.write(buffer) }
      end

      # 提取文件标记片段
      #
      # @param searching_file 搜索的文件
      # @param begin_mark 开始标记
      # @param end_mark 结束标记
      # @param included 是否包含标记段（默认为 true）
      # @return [Array<String>] 返回提取的片段
      #
      def fetch_segment(searching_file, begin_mark, end_mark, included = true)
        content = []
        extract_segment(searching_file, begin_mark, end_mark) { |line| content << line }
        included ? content.insert(0, begin_mark) << end_mark : content
      end

      # 向文件追加内容
      #
      # @param file_path 文件路径
      # @param content 追加的内容
      #
      def append_content!(file_path, content)
        UILogger.debug "向文件 #{file_path} 追加内容: #{content}"
        File.open(file_path, 'a') { |f| f.write(content) }
      end

      private

      # 提取内容片段
      #
      # @param searching_file 搜索的文件
      # @param begin_mark 开始标记
      # @param end_mark 结束标记
      # @@param &block 回调片段内容
      #
      def extract_segment(searching_file, begin_mark, end_mark)
        File.open(searching_file) do |f|
          segment_begin = false
          f.readlines.each do |line|
            segment_begin ||= line =~ /#{begin_mark}/
            break if segment_begin && line =~ /#{end_mark}/

            yield line if segment_begin
          end
        end
      end
    end
  end
end
