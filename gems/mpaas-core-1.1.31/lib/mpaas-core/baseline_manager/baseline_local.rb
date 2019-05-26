# frozen_string_literal: true

# baseline_local.rb
# MpaasKit
#
# Created by quinn on 2019-03-03.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 基线管理，本地 sdk 相关
  #
  class BaselineManager
    # 本地安装过的基线版本
    #
    # @return [Array]
    #
    def local_installed_baseline
      Dir.foreach(baseline_dir).select { |entry| entry =~ /^\d+\.\d+\.\d+$/ }.compact
    end

    # 本地安装过的最新基线版本
    #
    # @return [String]
    #
    def local_latest_baseline
      local_installed_baseline.max { |x, y| VersionCompare.compare(x).with(y) }
    end

    # 获取本地 SDK 信息
    #
    # @param [String] baseline
    # @return [Array]
    #
    def local_sdk_info(baseline)
      return [] unless local_installed_baseline.include?(baseline)
      if basic_info.active_v4
        # 只返回 component 的模块
        read_sdk_info(baseline, LocalPath.sdk_home_dir, /^[A-Z].+/).select do |info|
          info[:group] == 'component'
        end
      else
        read_sdk_info(baseline, LocalPath.sdk_module_install_dir)
      end
    end

    private

    # 读取本地的 sdk 信息
    #
    # @param [String] baseline
    # @param [Pathname] module_repo_dir
    # @param [Regex] match_reg 模块名称匹配的正则，默认匹配目录下所有文件
    # e.g. { name: xx, versions: [x.x.x, ...], title: xx,
    #        description: xx, releaseNote: xx, dependencies: {xxx: x.x.x} }
    #
    def read_sdk_info(baseline, module_repo_dir, match_reg = /.*/)
      component_info = load_component_info(baseline)
      Dir.foreach(module_repo_dir).reject { |e| %w[. ..].include?(e) }.map do |entry|
        next unless entry =~ match_reg
        # 查找本地
        path = module_repo_dir + entry
        next unless File.directory?(path)
        # 所有安装的版本
        versions = Dir.foreach(path).select { |sub| sub =~ /^\d+\.\d+\.\d+$/ }.compact
        info = component_info['modules'].find { |m| m['name'] == entry }&.map { |k, v| [k.to_sym, v] }.to_h
        { :name => entry, :versions => versions, :path => path }.merge(info) unless info.nil? || info.empty?
      end.compact
    end
  end
end
