# frozen_string_literal: true

# baseline_env.rb
# MpaasKit
#
# Created by quinn on 2019-02-24.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # mpaas 环境，基线相关环境
  #
  class MpaasEnv
    class << self
      # mpaas 基线地址
      #
      # @return [String]
      #
      def baseline_home_uri
        mpaas_base_uri + env_info['BASELINE']['Home']
      end

      # mpaas 基线版本地址
      #
      # @return [String]
      #
      def baseline_manifest_uri
        baseline_home_uri + env_info['BASELINE']['Manifest']
      end

      # mpaas 基线配置文件地址
      #
      # @param [String] version 基线版本
      # @return [String]
      #
      def baseline_component_uri(version)
        baseline_home_uri + '/' + version + env_info['BASELINE']['Component']
      end

      # 基线版本，4.0版本逻辑
      #
      def baseline_version_uri
        'http://mpaas-ios.oss-cn-hangzhou.aliyuncs.com/mPaaS-Dependency-Latest-Version/VERSION.txt'
      end

      # component 文件基础地址，4.0版本逻辑
      #
      def component_base_uri
        'http://mpaas-ios.oss-cn-hangzhou.aliyuncs.com/mPaaS-Dependency'
      end
    end
  end
end
