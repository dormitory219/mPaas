# frozen_string_literal: true

# search.rb
# MpaasKit
#
# Created by quinn on 2019-03-03.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class Command
    class Sdk
      # 查找 SDK 信息
      #
      class Search < Sdk
        def summary
          '查找 mPaaS 的组件 SDK 信息'
        end

        def define_parser(parser)
          parser.description = summary
          parser.add_argument('-b VERSION', '--baseline=VERSION',
                              :desc => '指定的基线版本，默认为最新基线',
                              :default => -> { nil }) { |opt| @baseline = opt }
          parser.add_argument('-d', '--details',
                              :desc => '展示组件 SDK 的详细信息') { |opt| @show_detail = opt }
          parser.add_argument('-l', '--local',
                              :desc => '在本地安装的 SDK 中查找') { |opt| @search_local = opt }
          parser.add_argument('NAME', :desc => '查找的 SDK 名称，支持模糊查询') { |opt| @name = opt }
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
          if @search_local
            sdk_info = baseline_manager.local_sdk_info(baseline_version)
            print_local_sdk_info(sdk_info.select { |info| info[:name].downcase.include?(@name.downcase) })
          else
            sdk_info = baseline_manager.remote_sdk_info(baseline_version)
            print_remote_sdk_info(sdk_info.select { |info| info[:name].downcase.include?(@name.downcase) })
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

        # 打印本地 SDK 信息
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
          if @search_local
            # 本地查找才显示安装目录
            detail_info += install_dir_info(info)
          else
            detail_info << INDENT + "新功能: #{info[:releaseNote]}"
            if info.key?(:dependencies)
              detail_info << INDENT + "依赖模块: #{info[:dependencies].map { |k, v| "#{k} (#{v})" }.join(', ')}"
            end
          end
          detail_info << ''
          detail_info << INDENT + info[:description]
          detail_info << ''
          detail_info
        end

        # 安装目录信息
        #
        # @param [Hash] info
        # @return [Hash]
        #
        def install_dir_info(info)
          install_info = []
          versions = info[:versions]
          if versions.count > 1
            install_info << INDENT + '安装目录'
            install_info += versions.map { |version| INDENT + "(#{version}): #{info[:path] + version}" }
          else
            install_info << INDENT + "安装目录: #{info[:path] + versions.first}"
          end
          install_info
        end
      end
    end
  end
end
