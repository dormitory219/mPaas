# frozen_string_literal: true

# local_path.rb
# MpaasKit
#
# Created by quinn on 2019-01-08.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # mpaas 本地路径
  #
  class LocalPath
    class << self
      # mpaas home 路径
      #
      # @return [Pathname]
      #
      def home_dir
        @home_dir ||= Pathname.new('/Users/Shared/.mpaaskit')
      end

      # mpaas sdk 路径
      #
      # @return [Pathname]
      #
      def sdk_home_dir
        @sdk_home_dir ||= Pathname.new('/Users/Shared/.mpaaskit_sdk')
      end

      # mpaas sdk 工程包本地仓库
      #
      # @return [Pathname]
      #
      def sdk_repo_dir
        sdk_home_dir + 'repo'
      end

      # 模块安装目录
      #
      # @return [Pathname]
      #
      def sdk_module_install_dir
        sdk_repo_dir + 'modules'
      end

      # 工程包安装目录
      #
      # @return [Pathname]
      #
      def sdk_framework_install_dir
        sdk_repo_dir + 'frameworks'
      end

      # mpaas gem 安装路径
      #
      # @return [Pathname]
      #
      def gem_home_dir
        @gem_home_dir ||= Pathname.new('/Users/Shared/.mpaaskit_gems')
      end

      # 日志路径
      #
      # @return [Pathname]
      #
      def log_dir
        @log_dir ||= home_dir + 'log'
      end

      # 诊断报告路径
      #
      # @return [Pathname]
      #
      def report_dir
        log_dir + 'DiagnosticReports'
      end

      # 资源目录
      #
      # @return [Pathname]
      #
      def resource_dir
        path = Pathname.new(caller_locations(2, 1)[0].path)
        path = path.parent while path.basename.to_s != 'lib'
        path.join('../resources')
      end

      # 二进制文件目录
      #
      # @return [Pathname]
      #
      def bin_dir
        path = Pathname.new(caller_locations(2, 1)[0].path)
        path = path.parent while path.basename.to_s != 'lib'
        path.join('../bin')
      end
    end
  end
end
