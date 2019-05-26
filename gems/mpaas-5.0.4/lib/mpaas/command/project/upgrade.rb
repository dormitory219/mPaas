# frozen_string_literal: true

# upgrade.rb
# MpaasKit
#
# Created by quinn on 2019-02-20.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class Command
    class Project
      # 更新模块命令
      #
      class Upgrade < Project
        def summary
          '更新模块'
        end

        def define_parser(parser)
          parser.description = summary
          parser.add_argument('-p', '--project=PATH',
                              :desc => '待编辑工程的.xcodeproj文件路径', :require => true,
                              &proc { |opt| options[:project] = opt })
          parser.add_argument('-t', '--target=TARGET',
                              :desc => '待编辑工程的target名称', :require => true,
                              &proc { |opt| options[:target] = opt })
          parser.add_argument('-b', '--baseline=VERSION',
                              :desc => '升级的基线版本') { |opt| options[:baseline] = opt }
          parser.add_argument('-m', '--modules=A,B,', Array,
                              :desc => '升级的 mpaas 模块，如果不指定 version 表示升级到最新版本',
                              &proc { |opt| options[:update_modules] = opt })
          parser.add_argument('--check', :desc => '检查工程的模块升级信息') { |opt| options[:only_check] = opt }
          parser.add_argument('--copy',
                              :desc => '是否是copy模式') { |opt| options[:copy] = opt }
        end

        def validation
          xcodeproj_path = Pathname.new(options.fetch(:project))
          assert(xcodeproj_path.exist?, "指定的工程文件不存在: #{xcodeproj_path}")
        end

        def run(argv)
          super(argv)
          validation
          project = ProjectGenerator.load_from_path(Pathname.new(options.fetch(:project)), options.fetch(:target))
          if project.mpaas_project?
            options[:config] = project.app_info_file_path(project.active_target)
            parse_basic_info
            options[:only_check] ? check_upgrade_info(project) : perform_upgrade(project)
          else
            UILogger.error('指定的工程非 mpaas 工程')
            exit(12)
          end
        end

        private

        # 解析
        def parse_basic_info
          options[:name] = File.basename(options.fetch(:project), '.*')
          options[:path] = File.dirname(options.fetch(:project))
          BasicInfo.instance.parse_options(options)
        end

        # 检查工程的升级信息
        #
        # @param [XCProjectObject] project 加载的工程
        #
        def check_upgrade_info(project)
          upgrade_info = ModuleManager.new(project).check_update_info
          UILogger.info(upgrade_info.to_json) unless upgrade_info.nil?
        end

        # 执行升级模块
        #
        # @param [XCProjectObject] project 加载的工程
        #
        def perform_upgrade(project)
          if options.key?(:baseline)
            print_result_message(ModuleManager.new(project).update_all_modules(options[:baseline]),
                                 '升级基线成功', '升级基线失败', 11)
          else
            modules = format_modules_argument(options.fetch(:update_modules, []))
            print_result_message(ModuleManager.new(project).update_module(*modules),
                                 '升级模块成功', '升级模块失败', 11)
          end
        end
      end
    end
  end
end
