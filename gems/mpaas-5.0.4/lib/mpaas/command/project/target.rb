# frozen_string_literal: true

# target.rb
# MpaasKit
#
# Created by quinn on 2019-01-20.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class Command
    class Project
      # target 相关的信息
      #
      class Target < Project
        def summary
          '获取工程的 target 信息'
        end

        def define_parser(parser)
          parser.description = summary
          parser.add_argument('-p', '--project=PATH',
                              :desc => '读入工程的.xcodeproj文件或.xcworkspace文件路径',
                              :require => true) { |opt| @project = opt }
          parser.add_argument('-l', '--list',
                              :desc => '显示所有target名称列表') { |opt| @list = opt }
          parser.add_argument('--json-format',
                              :desc => '以json格式输出') { |opt| @json_format = opt }
        end

        def run(argv)
          super(argv)
          UILogger.info(XcodeHelper.parse_project_structure(Pathname.new(@project)).to_json) if @list && @json_format
        end
      end
    end
  end
end
