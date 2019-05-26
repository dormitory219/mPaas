# frozen_string_literal: true

# edit.rb
# MpaasKit
#
# Created by quinn on 2019-01-20.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class Command
    class Project
      # 编辑工程，已有工程添加/删除模块
      #
      class Edit < Project
        def summary
          '对已有工程进行编辑，包括模块的新增和删除'
        end

        def define_parser(parser)
          parser.description = summary
          parser.add_argument('-p PROJECT', '--project=PATH',
                              :desc => '待编辑工程的.xcodeproj文件路径', :require => true,
                              &proc { |opt| options[:project] = opt })
          parser.add_argument('-c CONFIG', '--cloud-config=FILE',
                              :desc => '应用对应的云端数据配置文件', :require => true,
                              &proc { |opt| options[:config] = opt })
          parser.add_argument('-t TARGET', '--target=TARGET',
                              :desc => '待编辑工程的target名称', :require => true,
                              &proc { |opt| options[:target] = opt })
          parser.add_argument('-a A,B', '--add=A,B,', Array,
                              :desc => '新增的 mpaas 模块') { |opt| options[:add_modules] = opt }
          parser.add_argument('-d A,B', '--del=A,B,', Array,
                              :desc => '移除的 mpaas 模块') { |opt| options[:del_modules] = opt }
          parser.add_argument('--copy',
                              :desc => '是否是copy模式') { |opt| options[:copy] = opt }
        end

        def run(argv)
          super(argv)
          validation
          parse_basic_info
          add_modules = options.fetch(:add_modules, [])
          del_modules = options.fetch(:del_modules, [])
          return if add_modules.empty? && del_modules.empty?

          project = ProjectGenerator.load_from_path(Pathname.new(options.fetch(:project)), options.fetch(:target))
          ModuleManager.new(project).edit_module(add_modules, del_modules)
          UILogger.info '编辑模块成功'
        end

        private

        # 解析
        def parse_basic_info
          options[:name] = File.basename(options.fetch(:project), '.*')
          options[:path] = File.dirname(options.fetch(:project))
          BasicInfo.instance.parse_options(options)
        end

        # 校验参数
        #
        # @return [Array<Bool, String>]
        #         校验是否通过，校验失败的消息内容
        #
        def validation
          # 检查输入工程是否存在
          xcodeproj_path = Pathname.new(options.fetch(:project))
          assert(xcodeproj_path.exist?, "指定的工程文件不存在: #{xcodeproj_path}")
          # 检查云端数据是否存在
          config_file = options[:config]
          assert(File.exist?(config_file), "指定的云端数据配置文件不存在: #{config_file}")
        end
      end
    end
  end
end
