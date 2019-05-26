# frozen_string_literal: true

# sg_image_generator.rb
# MpaasKit
#
# Created by quinn on 2019-01-09.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 无线保镖图片工具
  #
  class SGImageGenerator
    require 'base64'

    class << self
      # 转换图片二进制内容
      #
      # @param [String] base64_str 图片的 base64 字符串
      # @return [String] 二进制串
      #
      def image_bin(base64_str)
        return nil if base64_str.nil? || base64_str.empty?
        # 生成串
        Base64.decode64(base64_str)
      end

      # 转换图片文件
      #
      # @param [String] base64_str 图片的 base64 字符串
      # @param [String] output_dir 文件输出的目录
      #
      def image_file(base64_str, output_dir)
        content = image_bin(base64_str)
        File.open("#{output_dir}/#{Constants::SG_IMAGE_FILE_NAME}", 'wb') { |f| f.write(content) }
        !content.nil?
      end

      # 输出图片文件
      #
      # @param [String] config_file
      # @param [String] jpg_version
      # @param [String] output_dir
      # @return [Bool] 生成成功或失败
      #
      def output_image_file(config_file, jpg_version, output_dir, app_secret)
        image_file(request_image_base64(config_file, jpg_version, app_secret), output_dir)
      end

      private

      # 请求图片的 base64 串
      #
      # @param [String] config_file
      # @param [String] jpg_version
      # @param [String] app_secret
      # @return [String, nil]
      #
      def request_image_base64(config_file, jpg_version, app_secret)
        # 请求 app secret
        raise '未提供 app secret，无法生成无线保镖图片' if app_secret.nil?
        # 请求图片
        app_info = AppInfoHelper.app_info_from_config(config_file)
        uri = MpaasEnv.mpaas_sg_image_uri(app_info.app_id, app_info.workspace_id, app_secret,
                                          app_info.bundle_id, jpg_version)
        res = DownloadKit.download_string(uri)
        return nil if res.nil?
        # 解析
        data = JSON.parse(res).fetch('data', {})
        data.fetch('data', nil) if data.fetch('success', false)
      end
    end
  end
end
