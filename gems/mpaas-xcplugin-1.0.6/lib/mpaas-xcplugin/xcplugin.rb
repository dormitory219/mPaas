# frozen_string_literal: true

# xcplugin.rb
# MpaasKit
#
# Created by quinn on 2019-01-16.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # xcode 插件
  #
  module XCPlugin
    require_relative 'constant'

    # 安装
    #
    class Installer
      class << self
        # 以指定命令行工具的版本，更新插件
        # 如果本地未安装，会安装适配的最新版本
        #
        # @param [String] cli_version 当前 mpaas kit 版本号
        # @return [Bool] 是否成功
        #
        def check_for_updates(cli_version)
          # 读本地插件版本
          plugin_version = read_local_plugin_version
          # 读更新版本信息
          version = read_update_version(cli_version, plugin_version)
          if version
            if plugin_version.nil?
              UILogger.info("安装 Xcode 插件: #{version}")
            else
              UILogger.info("更新 Xcode 插件: from #{plugin_version} to #{version}")
            end
            update(version)
          else
            plugin_version.nil? ? UILogger.error('未找到匹配的 Xcode 插件') : UILogger.info('已经是最新版本，无需更新')
            false
          end
        end
        alias install check_for_updates

        # 安装 xcode 插件的版本号
        #
        # @return [String]
        #
        def version
          installed? ? read_local_plugin_version : nil
        end

        # 更新到最新 xcode 插件版本
        # 等同于安装 xcode 插件
        #
        # @return [Bool] 是否成功
        #
        def update_latest
          UILogger.info '更新 xcode 插件最新版本'
          # 直接在 latest 地址下载并安装
          download_and_install(MpaasEnv.xcode_plugin_latest_uri)
        end

        # 更新到某个版本
        #
        # @param [String] plugin_version 下载 xcode 插件的版本号
        # @return [Bool] 是否成功
        #
        def update(plugin_version)
          # 下载解压
          plugin_uri = MpaasEnv.xcode_plugin_repo_uri + '/' + "mpaas-plugin-#{plugin_version}.tar.gz"
          download_and_install(plugin_uri)
        end

        # 从本地包安装
        #
        # @param [String] path 本地包路径
        # @return [Bool] 是否成功
        #
        def install_from_local(path)
          UILogger.info "从本地安装包安装: #{path}"
          uninstall
          # 安装，如果插件目录不存在，创建目录
          FileUtils.mkdir_p(Constant.xcode_plugin_dir) unless File.exist?(Constant.xcode_plugin_dir)
          CommandExecutor.exec("tar xzvf #{path} -C #{xcode_plugin_path}")
          UILogger.info '安装成功!'
          true
        end

        # 卸载 xcode 插件
        #
        # @param &block block 回调，是否可以卸载
        #
        def uninstall
          return unless installed?
          # 卸载
          UILogger.info "卸载本地已安装的插件: #{xcode_plugin_path}"
          FileUtils.remove_entry(xcode_plugin_path)
        end

        # 本地 xcode 插件是否安装
        #
        # @return [Bool]
        #
        def installed?
          xcode_plugin_path.exist?
        end

        # 插件文件路径
        #
        # @return [Pathname]
        #
        def xcode_plugin_path
          @xcode_plugin_path ||= Constant.xcode_plugin_dir + Constant.xcode_plugin_name
        end

        private

        # 读取本地 xcode 插件的版本信息
        # 未安装，返回 nil
        #
        # @return [String, nil] 版本号
        #
        def read_local_plugin_version
          plist_path = xcode_plugin_path + 'Contents/Info.plist'
          PlistAccessor.fetch_entry(plist_path, ['CFBundleShortVersionString']) if File.exist?(plist_path)
        end

        # 读取更新信息
        #
        # @param [String] cli_version 当前 mpaas kit 版本号
        # @return [String, nil] 更新的具体版本号
        #
        def read_update_version(cli_version, plugin_version)
          content = DownloadKit.download_string(Constant.manifest_uri)
          raise '读取更新信息失败' if content.nil?
          # 查找匹配的版本号
          find_match_version(JSON.parse(content), cli_version, plugin_version)
        end

        # 查找匹配的更新版本
        # 匹配当前 mpaas kit 版本的最新 xcode 插件版本
        #
        # @param [Hash] manifest
        # @param [String] cli_version
        # @param [String] plugin_version
        # @return [String]
        #
        def find_match_version(manifest, cli_version, plugin_version)
          # 遍历版本信息，选取匹配的版本
          supported_versions = manifest.select do |_, info|
            version_in_range(cli_version, info['min-compatible'], info['max-compatible'])
          end
          # 支持的最新版本
          latest_version = supported_versions.to_a.max { |a, b| VersionCompare.compare(a[0]).with(b[0]) }.first
          # 本地没有插件，或者最新插件版本号大于本地插件版本
          latest_version if plugin_version.nil? || VersionCompare.compare(latest_version).greater_than?(plugin_version)
        end

        # 下载并安装
        #
        # @param [String] uri 下载地址
        # @return [Bool] 是否成功
        #
        def download_and_install(uri)
          result = false
          UILogger.debug "下载 xcode 插件: #{uri}"
          tmp_dir = Dir.mktmpdir
          DownloadKit.download_file_with_progress(uri, tmp_dir, true) do |success|
            if success
              # 卸载
              uninstall
              # 安装，如果插件目录不存在，创建目录
              FileUtils.mkdir_p(Constant.xcode_plugin_dir) unless File.exist?(Constant.xcode_plugin_dir)
              FileUtils.mv(tmp_dir + '/' + Constant.xcode_plugin_name, Constant.xcode_plugin_dir)
              UILogger.info('安装成功!')
              result = success
            else
              UILogger.error('下载失败！')
            end
          end
          FileUtils.remove_entry(tmp_dir)
          result
        end

        # 版本是否在范围内
        #
        # @param [String] version 版本号，格式x.x.x的字符串
        # @param [String] min 最小版本号，格式x.x.x的字符串
        # @param [String] max 最大版本号，格式x.x.x的字符串
        # @return [Bool]
        #
        def version_in_range(version, min, max)
          min = min.empty? ? '0.0.0' : min
          match = VersionCompare.compare(version).greater_than_or_equal?(min)
          match &&= VersionCompare.compare(version).smaller_than_or_equal?(max) unless max.empty?
          match
        end
      end
    end
  end
end