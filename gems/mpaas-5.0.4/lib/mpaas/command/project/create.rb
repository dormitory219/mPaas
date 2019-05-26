# frozen_string_literal: true

# create.rb
# MpaasKit
#
# Created by quinn on 2019-01-14.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class Command
    class Project < Command
      # 创建工程命令
      #
      class Create < Project
        include BasicInfo::Mixin

        def summary
          '创建相关工程'
        end

        def define_parser(parser)
          parser.description = '可以创建系统 xcode 工程，mpaas 框架工程，同时也可以选择是否创建对应 pod 工程'
          basic_argument(parser)
          ext_argument(parser)
        end

        def run(argv)
          super(argv)
          # 校验参数
          validation
          # 解析基础数据信息
          basic_info.parse_options(options)
          # 创建工程
          project = ProjectGenerator.new(options.fetch(:project_type), options.fetch(:app_type)).create_app_project
          # mpaas 工程添加模块
          if project.mpaas_project?
            modules = options.fetch(:modules, [])
            modules = format_modules_argument(modules)
            ModuleManager.new(project).add_module(*modules)
          end
          UILogger.info 'xcode 工程创建成功'
        end

        private

        # 必要参数
        #
        # @param parser [Parser]
        #
        def basic_argument(parser)
          parser.add_argument('NAME', :desc => '创建的工程名称') { |opt| options[:name] = opt }
          parser.add_argument('-o', '--output=PATH',
                              :desc => '创建的工程路径(默认为执行命令的当前目录)',
                              :default => -> { FileUtils.pwd }) { |opt| options[:path] = opt }
          parser.add_argument('-c', '--cloud-config=FILE',
                              :desc => '应用对应的云端数据配置文件',
                              :default => -> { '' }) { |opt| options[:config] = opt }
          parser.add_argument('--modules=A,B', Array,
                              :desc => '添加的 mpaas 模块',
                              :default => -> { [] }) { |opt| options[:modules] = opt }
        end

        # 扩展参数
        #
        # @param parser [Parser]
        #
        def ext_argument(parser)
          parser.add_argument('--org=NAME',
                              :desc => '工程的组织名称') { |opt| options[:org] = opt }
          parser.add_argument('--class-prefix=PREFIX',
                              :desc => '工程中类名前缀') { |opt| options[:clz_prefix] = opt }
          parser.add_argument('--project-type=TYPE', %i[sys sys_pod mpaas mpaas_pod],
                              :desc => '工程的类型(系统单工程，系统pod工程， mpaas框架工程， mpaas框架pod工程)',
                              :default => -> { :mpaas }, &proc { |opt| options[:project_type] = opt })
          parser.add_argument('--app-type=TYPE', %i[tab drawer navigation empty],
                              :desc => '创建应用的模版类型(标签应用，抽屉应用，导航栏应用，空应用)',
                              :default => -> { :tab }, &proc { |opt| options[:app_type] = opt })
          parser.add_argument('--force',
                              :desc => '如果创建的输出目录存在是否强制覆盖') { |opt| options[:force] = opt }
          parser.add_argument('--copy',
                              :desc => '是否是copy模式') { |opt| options[:copy] = opt }
        end

        # 校验参数
        #
        def validation
          # 校验保存目录名称不为空
          UILogger.warning('无法获取工程名称') if options[:name].nil? || options[:name].empty?
          assert(!options[:name].nil? && !options[:name].empty?, '无法读取工程名称')
          # 输出目录如果不存在，建立输出目录
          FileUtils.mkdir_p(options[:path]) unless File.exist?(options[:path])
          # 校验工程目录
          validate_project_dir
          # 校验云端配置
          validate_config_file
        end

        # 校验工程是否存在
        #
        def validate_project_dir
          # 检查目标路径是否已存在
          project_dir = Pathname.new(options[:path]) + options[:name]
          return unless Dir.exist?(project_dir)
          # 非强制删除，需要询问
          unless options.fetch(:force, false)
            override = InteractionAssistant.ask_with_answers('目标文件已经存在，是否覆盖', %w[y n])
            assert(override == 'y', "目标文件已经存在: #{project_dir}")
          end
          # 覆盖，则删除目录，强制校验目录和 path 不相同，防止父目录被删除
          can_remove = Dir.exist?(project_dir) && project_dir.to_s != options[:path]
          FileUtils.remove_entry(project_dir) if can_remove
        end

        # 校验配置文件
        #
        def validate_config_file
          system_project = %i[sys sys_pod].include?(options[:project_type])
          # 非系统工程，检查云端数据是否存在
          config_file = options.fetch(:config)
          assert(system_project || File.exist?(config_file),
                 "指定的云端数据配置文件不存在: #{config_file}")
        end
      end
    end
  end
end
