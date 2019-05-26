# frozen_string_literal: true

# baseline_version.rb
# MpaasKit
#
# Created by quinn on 2019-02-24.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 基线管理，基线版本相关
  #
  class BaselineManager
    include BasicInfo::Mixin

    # 新特性支持的最低版本
    #
    # @return [String]
    #
    def new_feature_min_version
      @new_feature_min_version ||= request_baseline_manifest.fetch('MSV', nil)
    end

    # 所有支持的基线版本列表
    #
    # @return [Array]
    #
    def supported_versions
      @supported_versions ||= request_baseline_manifest.fetch('versions', [])
    end

    # 最新基线版本号
    #
    # @return [String]
    #
    def version
      @version ||= parse_latest_version(supported_versions)
    end

    # 检查基线更新
    #
    def check_for_updates
      return nil unless @using_new_feature_checked
      # 兼容 v4
      if basic_info.active_v4
        check_for_updates_old
        return
      end
      UILogger.debug '检查基线版本更新'
      # 重新请求，最新版本号
      @supported_versions = request_baseline_manifest['versions']
      @version = parse_latest_version(@supported_versions)
      # 获取成功
      UILogger.debug("获取最新 SDK 信息: #{@version}")
      # 加载最新基线的所有模块
      @latest_modules = load_modules(@version)
    end

    private

    # 解析最新的版本号
    #
    # @return [String]
    #
    def parse_latest_version(versions)
      max_version = versions.first
      versions.each do |version|
        max_version = version if VersionCompare.compare(version).greater_than?(max_version)
      end
      max_version
    end

    # 请求基线配置
    #
    # @return [Hash]
    #
    def request_baseline_manifest
      manifest_json = DownloadKit.download_string(MpaasEnv.baseline_manifest_uri)
      raise '请求基线版本失败，请检查网络' if manifest_json.nil?
      # 获取配置内容
      JSON.parse(manifest_json)
    end
  end
end
