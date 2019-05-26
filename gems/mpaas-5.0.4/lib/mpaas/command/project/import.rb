# frozen_string_literal: true

# import.rb
# MpaasKit
#
# Created by quinn on 2019-01-30.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class Command
    class Project
      # 导入云端数据
      #
      class Import < Project
        def summary
          '向 mpaas 工程导入云端数据'
        end

        def define_parser(parser)
          parser.description = summary
          parser.add_argument('-p', '--project=PATH',
                              :desc => '待编辑工程的.xcodeproj文件路径', :require => true,
                              &proc { |opt| options[:project] = opt })
          parser.add_argument('-c', '--cloud-config=FILE',
                              :desc => '应用对应的云端数据配置文件', :require => true,
                              &proc { |opt| options[:config] = opt })
          parser.add_argument('-t', '--target=TARGET',
                              :desc => '待编辑工程的target名称', :require => true,
                              &proc { |opt| options[:target] = opt })
        end

        def run(argv)
          super(argv)
          UILogger.section_info('开始导入云端数据')
          validation
          parse_basic_info
          project = ProjectGenerator.load_from_path(Pathname.new(options[:project]), options[:target])
          ModuleManager.new(project).import_data
        end

        # 校验参数
        #
        def validation
          # 检查输入工程是否存在
          xcodeproj_path = Pathname.new(options.fetch(:project))
          assert(xcodeproj_path.exist?, "指定的工程文件不存在: #{xcodeproj_path}")
          # 检查云端数据是否存在
          config_file = options[:config]
          assert(File.exist?(config_file), "指定的云端数据配置文件不存在: #{config_file}")
        end

        private

        # 解析
        #
        def parse_basic_info
          options[:name] = File.basename(options.fetch(:project), '.*')
          options[:path] = File.dirname(options.fetch(:project))
          BasicInfo.instance.parse_options(options)
        end

        # 保存云端数据配置文件
        #
        # @param [Pathname] dir
        #
        def save_config_file(dir)
          # 保存在工程 src root
          app_id = BasicInfo.instance.app_info['appId']
          workspace_id = BasicInfo.instance.app_info['workspaceId']
          config_file_name = app_id + '-' + workspace_id + '-' + 'iOS.config'
          File.open(dir + config_file_name, 'w') do |f|
            f.write(JSON.pretty_generate(BasicInfo.instance.app_info))
          end
        end
      end
    end
  end
end
