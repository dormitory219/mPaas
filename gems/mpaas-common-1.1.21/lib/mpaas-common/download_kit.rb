# frozen_string_literal: true

# download_kit.rb
# MpaasKit
#
# Created by quinn on 2019-01-09.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 下载工具类
  #
  class DownloadKit
    require 'open-uri'
    require 'tmpdir'

    class << self
      # 直接下载内容字符串
      #
      # @param uri 下载地址
      # @return [String, nil] 如果下载失败返回 nil
      #
      def download_string(uri)
        URI.parse(uri).read
      rescue OpenURI::HTTPError, SocketError => e
        UILogger.warning(e.message)
        nil
      end

      # 带进度下载
      #
      # @param [String] uri 下载地址
      # @param [Object] dest 保存目录/文件
      # @param [Object] unzip 是否对下载文件解压
      # @return [Bool] 是否下载成功，如果解压，解压失败也返回 nil
      #
      def download_file_with_progress(uri, dest, unzip = false)
        total_size = nil
        URI.parse(uri).open(
          :content_length_proc => ->(content_length) { total_size = content_length },
          :progress_proc => lambda { |size|
            percent = size * 1.0 / total_size * 100
            UILogger.console_print(format("\r%.2f %%", percent)) if total_size
            UILogger.console('') if percent >= 100
          }
        ) { |stream| write_file(dest, stream, unzip) }
        yield true if block_given?
      rescue OpenURI::HTTPError => e
        UILogger.warning e.message
        yield false if block_given?
      end

      # 下载文件
      #
      # @param uri 下载地址
      # @param dest 文件保存路径/解压路径
      # @param unzip 是否解压缩（默认不解压 false）
      # @return [Bool] 是否成功，如果使用解压，解压失败也返回 false
      #
      def download_file(uri, dest, unzip = false)
        URI.parse(uri).open { |stream| write_file(dest, stream, unzip) }
        yield true if block_given?
      rescue OpenURI::HTTPError => e
        UILogger.warning e.message
        yield false if block_given?
      end

      # 下载文件并选择指定内容保存
      # 只用与下载压缩的文件
      #
      # @param [String] uri
      # @param [String] dest
      # @param [String] pattern 文件路径的 glob pattern
      #
      def download_file_and_select(uri, dest, pattern = nil)
        URI.parse(uri).open { |stream| unzip_file_with_stream(dest, stream, pattern) }
        yield true if block_given?
      rescue OpenURI::HTTPError => e
        UILogger.warning e.message
        yield false if block_given?
      end

      private

      # 写入文件，根据是否压缩选择不同方法
      #
      # @param [String] file 目的文件
      # @param [IO] stream 流
      # @param [Bool] unzip 是否压缩
      #
      def write_file(file, stream, unzip)
        unzip ? unzip_file_with_stream(file, stream) : write_stream_to_file(file, stream)
      end

      # 按块写入文件
      #
      # @param [String] file
      # @param [IO] stream
      #
      def write_stream_to_file(file, stream)
        FileUtils.mkdir_p(File.dirname(file))
        File.open(file, 'wb') do |f|
          while (chuck = stream.read(1024))
            f.write(chuck)
          end
        end
      end

      # 下载内容解压到目录
      #
      # @param [String] dest
      # @param [IO] stream
      # @param [String] pattern 文件匹配的 pattern
      #
      def unzip_file_with_stream(dest, stream, pattern = nil)
        Dir.mktmpdir do |tmp_dir|
          # 保存到临时目录
          tmp_file_path = Pathname.new(tmp_dir) + 'tmp.tar.gz'
          write_stream_to_file(tmp_file_path, stream)
          # 创建目标目录
          FileUtils.mkdir_p(dest)
          if pattern.nil?
            # 解压
            output, status = CommandExecutor.exec("tar xzf #{tmp_file_path} -C #{dest}")
            raise CommandExecError('解压文件失败', output) unless status.success?
          else
            # 复制筛选匹配的文件
            filter_files(tmp_file_path, pattern).each { |p| FileUtils.mv(p, dest) }
          end
        end
      end

      # 筛选文件
      #
      # @param [String] zip_file_path 解压的文件
      # @param [String] pattern
      # @return [Array] 文件列表
      #
      def filter_files(zip_file_path, pattern)
        files = []
        Dir.chdir(File.dirname(zip_file_path)) do
          output, status = CommandExecutor.exec("tar xzf #{zip_file_path}")
          raise CommandExecError('解压文件失败', output) unless status.success?
          # 筛选匹配的文件
          files = Dir.glob(FileUtils.pwd + '/' + pattern)
        end
        files
      end
    end
  end
end
