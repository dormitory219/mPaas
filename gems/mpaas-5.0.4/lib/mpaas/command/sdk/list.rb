# frozen_string_literal: true

# list.rb
# MpaasKit
#
# Created by quinn on 2019-03-03.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class Command
    class Sdk
      # sdk 列表
      #
      class List < Sdk
        def summary
          '展示 mPaaS 组件 SDK 列表'
        end

        def define_parser(parser)
          parser.description = summary + '，默认展示本地安装的 SDK 信息'
          parser.add_argument('-b VERSION', '--baseline=VERSION',
                              :desc => '指定的基线版本，默认为最新基线',
                              :default => -> { nil }) { |opt| @baseline = opt }
          parser.add_argument('-d', '--details',
                              :desc => '展示组件 SDK 的详细信息') { |opt| @show_detail = opt }
          parser.add_argument('-r', '--remote',
                              :desc => '远程支持的所有 SDK 列表') { |opt| @list_remote = opt }
          parser.add_argument('--json-format',
                              :desc => '基线模块信息以 json 格式显示') { |opt| @json = opt }
        end

        def run(argv)
          super(argv)
          baseline_manager = BaselineManager.new
          baseline_manager.check_new_feature(@baseline)
          baseline_manager.check_for_updates
          print_sdk_info(baseline_manager)
        end

        private

        INDENT = ' ' * 4

        # 打印信息
        #
        # @param [BaselineManager] baseline_manager
        #
        def print_sdk_info(baseline_manager)
          baseline_version = @baseline || baseline_manager.version
          if @list_remote
            sdk_info = baseline_manager.remote_sdk_info(baseline_version)
            @json ? UILogger.info(sdk_info.to_json) : print_remote_sdk_info(sdk_info)
          else
            sdk_info = baseline_manager.local_sdk_info(baseline_version)
            @json ? UILogger.info(sdk_info.to_json) : print_local_sdk_info(sdk_info)
          end
        end

        # 打印远程 SDK 信息
        #
        # @param [Hash] sdk_info
        #
        def print_remote_sdk_info(sdk_info)
          print_info = ['-- REMOTE SDKS --']
          print_info << ''
          sdk_info.each do |info|
            print_info << "#{info[:name]} (#{info[:version]})"
            next unless @show_detail
            # 详细信息
            print_info += detail_part(info)
          end
          UILogger.info(print_info.join("\n"))
        end

        # 打印本地模块列表的信息
        #
        # @param [Hash] sdk_info
        #
        def print_local_sdk_info(sdk_info)
          print_info = ['-- LOCAL SDKS --']
          print_info << ''
          sdk_info.each do |info|
            print_info << "#{info[:name]} (#{info[:versions].join(', ')})"
            next unless @show_detail
            # 详细信息
            print_info += detail_part(info)
          end
          UILogger.info(print_info.join("\n"))
        end

        # 详情部分
        #
        # @param [Hash] info
        # @return [Array]
        #
        def detail_part(info)
          detail_info = []
          detail_info << INDENT + "名称: #{info[:title]}"
          unless @list_remote
            # 本地查找才显示安装目录
            versions = info[:versions]
            if versions.count > 1
              detail_info << INDENT + '安装目录'
              detail_info += versions.map { |version| INDENT + "(#{version}): #{info[:path] + version}" }
            else
              detail_info << INDENT + "安装目录: #{info[:path] + versions.first}"
            end
          end
          detail_info << ''
          detail_info << INDENT + info[:description]
          detail_info << ''
          detail_info
        end
      end
    end
  end
end
