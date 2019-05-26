# frozen_string_literal: true

# environment.rb
# MpaasKit
#
# Created by quinn on 2019-01-08.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # mpaas 环境
  #
  class MpaasEnv
    require 'yaml'
    require_relative 'environment/mpaas_kit_env'
    require_relative 'environment/baseline_env'

    class << self
      # mpaas oss 远程地址
      #
      # @return [String]
      #
      def mpaas_base_uri
        env_info['REMOTE']['Host']
      end

      # mpaas app center 远程地址
      #
      # @return [String]
      #
      def mpaas_app_center_uri
        env_info['APPCENTER']['Host']
      end

      # 无线保镖图片查询地址
      #
      # @param [String] app_id
      # @param [String] workspace_id
      # @param [String] app_secret
      # @param [String] identifier
      # @param [String] jpg_version
      # @return [String]
      #
      def mpaas_sg_image_uri(app_id, workspace_id, app_secret, identifier, jpg_version)
        param = +''
        param << '?appId=' + app_id
        param << '&systemType=IOS'
        param << '&workspaceId=' + workspace_id
        param << '&appSecret=' + app_secret
        param << '&identifier=' + identifier
        param << '&certRsaBase64=dasdasdasd'
        param << '&jpgVersion=' + jpg_version
        mpaas_app_center_uri + env_info['APPCENTER']['SecurityGuardImage'] + param
      end

      # mpaas sdk 仓库地址
      #
      # @return [String]
      #
      def sdk_repo_uri
        sdk_home_uri + env_info['SDK']['Repo']
      end

      # mpaas sdk 远程基础地址
      #
      # @return [String]
      #
      def sdk_home_uri
        mpaas_base_uri + env_info['SDK']['Home']
      end

      # mpaas sdk 文件地址
      #
      # @param [String] name
      # @param [String] version
      # @return [String]
      #
      def sdk_uri(name, version)
        sdk_repo_uri + '/' + name + '/' + "#{version.tr('.', '_')}.tar.gz"
      end

      # mpaas sdk 基础地址，4.0 版本使用
      #
      # @return [String]
      #
      def sdk_base_uri
        'http://mpaas-ios.oss-cn-hangzhou.aliyuncs.com/mPaaS-SDK-Repository'
      end

      # 加载本地环境配置，只加载一次
      #
      def load_from_config
        return unless @env_settings.nil?
        return unless File.exist?(env_config_file)
        # 将配置中的kv写入环境变量
        @env_settings = YAML.load_file(env_config_file).each { |k, v| ENV[k] = v }
      end

      # 当前的本地开发环境
      #
      # @return [String]
      #
      def current_env
        ENV['MPAAS_CURRENT_ENV']
      end

      # 清理环境
      #
      def clear
        FileUtils.remove_entry(env_config_file) if env_config_file.exist?
      end

      # 配置环境
      #
      # @param [String] env
      #
      def setup_config(env)
        clear
        File.open(env_config_file, 'wb') { |f| f.write("MPAAS_CURRENT_ENV: #{env}") }
      end

      private

      # 配置的环境信息
      #
      # @return [Hash]
      #
      def env_info
        @env_info ||= YAML.load_file(LocalPath.resource_dir + 'env.yml').fetch(ENV['MPAAS_CURRENT_ENV'] || 'prod')
      end

      # 环境配置文件
      #
      # @return [Pathname]
      #
      def env_config_file
        LocalPath.home_dir + '.mpaasenv'
      end
    end
  end
end
