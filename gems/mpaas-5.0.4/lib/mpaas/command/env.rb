# frozen_string_literal: true

# env.rb
# MpaasKit
#
# Created by quinn on 2019-01-16.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class Command
    # 环境子命令
    #
    class Env < Command
      def summary
        'mpaas 环境相关命令'
      end

      def define_parser(parser)
        parser.description = summary
        parser.add_argument('-c', '--configuration', :desc => '展示 mpaas 配置环境') { |opt| @conf = opt }
        parser.add_argument('--json-format', :desc => '以 json 字符串格式输出环境配置') { |opt| @json = opt }
      end

      def run(argv)
        super(argv)
        if @conf
          UILogger.info(conf_json) if @json
        else
          print_env_info
        end
      end

      private

      # 环境配置
      #
      # @return [String]
      #
      def conf_json
        <<~CONF
          {"SDK":{"Binary":"http://mpaas-ios.oss-cn-hangzhou.aliyuncs.com/mPaaS-SDK-Repository","Config":"http://mpaas-ios.oss-cn-hangzhou.aliyuncs.com/mPaaS-SDK-Config/Component.json","Component":"http://mpaas-ios.oss-cn-hangzhou.aliyuncs.com/mPaaS-SDK-Config/Component.json","HasFrameworkComponent":"http://mpaas-ios.oss-cn-hangzhou.aliyuncs.com/mPaaS-SDK-Config/HasFrameworkComponent.json"},"Authenticator":{"URI":"http://mpaas-ios.oss-cn-hangzhou.aliyuncs.com/mPaaS-SDK-Authenticator/Content.txt","Content":"This is real mPaaS SDK Repository."},"CONFIG":{"REMOTE_PATH_PREFIX":"http://mpaas-ios.oss-cn-hangzhou.aliyuncs.com"},"BASELINE":{"Dependency":"http://mpaas-ios.oss-cn-hangzhou.aliyuncs.com/mPaaS-Dependency","LatestVersion":"http://mpaas-ios.oss-cn-hangzhou.aliyuncs.com/mPaaS-Dependency-Latest-Version/VERSION.txt"}}
        CONF
      end

      # 打印环境信息
      #
      def print_env_info
        env_info = {
          :General => general_info_section,
          :Installation => installation_info_section,
          :Gems => gems_info_section
        }
        UILogger.info(@json ? JSON.pretty_generate(env_info) : format(env_info))
      end

      # 格式化环境信息
      #
      # @param [String] env_info
      #
      def format(env_info)
        print_stack = []
        env_info.each do |section, info_hash|
          print_stack << "-- #{section} --"
          print_stack << ''
          justification = info_hash.keys.map(&:size).max
          info_hash.each do |name, value|
            print_stack << name.to_s.rjust(justification) + ': ' + value
          end
          print_stack << ''
        end
        print_stack.join("\n")
      end

      # 通用信息段
      #
      # @return [Hash]
      #
      def general_info_section
        {
          'mPaaS Kit' => Mpaas::VERSION,
          'Xcode Plugin' => XCPlugin::Installer.version
        }.merge(SystemInfo.general)
      end

      # 安装信息段
      #
      # @return [Hash]
      #
      def installation_info_section
        { 'Executable Path' => $PROGRAM_NAME }
      end

      # 依赖 gem 库信息段
      #
      # @return [Hash]
      #
      def gems_info_section
        {
          'mpaas-env' => Mpaas::ENV_VERSION,
          'mpaas-common' => Mpaas::COMMON_VERSION,
          'mpaas-template' => Mpaas::TEMPLATE_VERSION,
          'mpaas-project' => Mpaas::PROJECT_VERSION,
          'mpaas-core' => Mpaas::CORE_VERSION,
          'mpaas-xcplugin' => Mpaas::XCPlugin::VERSION
        }
      end
    end
  end
end
