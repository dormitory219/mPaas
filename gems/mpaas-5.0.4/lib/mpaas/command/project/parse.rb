# frozen_string_literal: true

# parse.rb
# workspace
#
# Created by quinn on 2019-03-19.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class Command
    class Project
      # 解析工程
      #
      class Parse < Project
        def summary
          '解析 mPaaS 工程集成的模块'
        end

        def define_parser(parser)
          parser.description = summary
          parser.add_argument('-p PROJECT', '--project=PATH',
                              :desc => '待解析工程的 .xcodeproj 文件路径', :require => true,
                              &proc { |opt| options[:project] = opt })
          parser.add_argument('-t', '--target=TARGET',
                              :desc => '待解析工程的 target 名称', :require => true,
                              &proc { |opt| options[:target] = opt })
          parser.add_argument('--cross-over=VERSION',
                              :desc => '和某个基线版本交叉对比') { |opt| @cross_over = opt }
          parser.add_argument('--json',
                              :desc => '以 json 格式输出') { |opt| @json = opt }
        end

        def run(argv)
          super(argv)
          project = ProjectGenerator.load_from_path(Pathname.new(options.fetch(:project)), options.fetch(:target))
          if project.mpaas_project?
            options[:config] = project.app_info_file_path(project.active_target)
            parse_basic_info
            module_info = resolve_module_info(project)
            module_info = cross_over(module_info) unless @cross_over.nil?
            UILogger.info(module_info.to_json) if @json
          else
            UILogger.error('指定的工程非 mpaas 工程')
            exit(32)
          end
        end

        private

        # 交叉对比，替换模块名为新基线名称
        #
        # @param [Hash] module_info
        #
        def cross_over(module_info)
          BaselineManager.new.check_new_feature(@cross_over)
          module_info[:modules] = module_info[:modules].map do |k, v|
            [ModuleConfig.module_name(k), v]
          end.to_h
          module_info
        end

        # 解析模块信息
        #
        # @param [XCProjectObject] project
        # @return [Hash]
        #
        def resolve_module_info(project)
          resolver = Resolver.new(project)
          baseline_version = resolver.resolved_current_baseline
          BaselineManager.new.check_new_feature(baseline_version)
          modules = resolver.resolve_module_versions_info(options[:target])&.map do |k, v|
            # 原始的数据，转换名称
            [ModuleConfig.module_name(k), v]
          end.to_h
          copy_mode = resolver.resolve_copy_mode
          { :baseline => baseline_version, :modules => modules, :copy => copy_mode }
        end

        # 解析
        #
        def parse_basic_info
          options[:name] = File.basename(options.fetch(:project), '.*')
          options[:path] = File.dirname(options.fetch(:project))
          BasicInfo.instance.parse_options(options)
        end
      end
    end
  end
end
