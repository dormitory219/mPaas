# frozen_string_literal: true

# system_info.rb
# MpaasKit
#
# Created by quinn on 2019-01-08.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 系统信息
  #
  class SystemInfo
    require 'English'

    class << self
      # 基本信息
      #
      # @return [String]
      #
      def general
        {
          :Ruby => RUBY_DESCRIPTION,
          :RubyGems => Gem::VERSION,
          'Ruby Lib Path' => RbConfig::CONFIG['libdir'],
          :OS => mac_os_info,
          :Xcode => xcode_version,
          :Git => git_version
        }
      end

      # 系统所有安装的 Xcode
      #
      # @return [Array]
      #
      def installed_xcode_info
        `mdfind kMDItemCFBundleIdentifier=com.apple.dt.Xcode`.strip.split("\n")
      end

      # 系统运行的所有 Xcode 相关进程状态
      #
      # @return [Array]
      #
      def xcode_process_info
        `ps aux | grep Xcode.app | grep -v grep`.strip.split("\n")
      end

      # 系统状态信息
      #
      # @return [Array]
      #
      def mac_os_status
        `top -l 1 | head -n 10`.strip.split("\n")
      end

      # 系统信息
      #
      # @return [String]
      #
      def system_profiles
        output = `system_profiler SPHardwareDataType -detailLevel mini 2> /dev/null`.strip
        hash = output.split("\n").map(&:strip).reject(&:empty?).map do |line|
          k, v = line.split(':')
          [k, v]
        end.to_h
        'Model: ' + [
          hash.fetch('Model Identifier', nil),
          hash.fetch('Boot ROM Version', nil),
          hash.fetch('Number of Processors', '0') + ' processor',
          hash.fetch('Processor Name', nil),
          hash.fetch('Processor Speed', nil),
          hash.fetch('Memory', nil),
          'SMC ' + hash.fetch('SMC Version (system)', '')
        ].compact.join(',')
      end

      # 用户名
      #
      # @return [String]
      #
      def user_name
        # 如果没配置 git 用户名，取登录系统的用户名
        @user_name ||= (git_config_user_name || `whoami`.strip)
      end

      # 系统版本
      #
      # @return [String]
      #
      def mac_os_version
        _, version, = `sw_vers`.strip.split("\n").map { |line| line.split(':').last.strip }
        version
      end

      # xcode 版本
      #
      # @return [String]
      #
      def xcode_version
        version, build = `xcodebuild -version`.strip.split("\n").map { |line| line.split(' ').last }
        raise '无法定位 xcode，检查是否安装 xcode command line tool!' unless $CHILD_STATUS.success?
        "#{version} (#{build})"
      end

      # ruby 版本
      #
      # @return [String]
      #
      def ruby_version
        RUBY_VERSION
      end

      # ios sdk 版本
      #
      # @return [String]
      #
      def ios_sdk_version
        version = `xcrun -sdk iphoneos --show-sdk-version 2>/dev/null`.strip
        raise '无法定位系统 SDK，检查是否安装 xcode command line tool!' unless $CHILD_STATUS.success?

        version
      end

      # ios sdk 路径
      #
      # @return [String]
      #
      def ios_sdk_path
        path = `xcrun -sdk iphoneos --show-sdk-path 2>/dev/null`.strip
        raise '无法定位系统 SDK，检查是否安装 xcode command line tool!' unless $CHILD_STATUS.success?

        path
      end

      private

      # 取 git 配置的用户名
      #
      def git_config_user_name
        `git config user.name 2>/dev/null`.strip
      end

      # git 版本号
      #
      # @return [String]
      #
      def git_version
        `git --version`.strip.split("\n").first
      end

      # mac 系统信息
      #
      # @return [String]
      #
      def mac_os_info
        product, version, build = `sw_vers`.strip.split("\n").map { |line| line.split(':').last.strip }
        "#{product} #{version} (#{build})"
      end
    end
  end
end
