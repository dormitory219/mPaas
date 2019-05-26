# frozen_string_literal: true

# appinfo.rb
# MpaasKit
#
# Created by quinn on 2019-03-05.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class Command
    class Inst
      # 应用信息命令
      #
      class Appinfo < Inst
        def summary
          '获取应用相关信息'
        end

        def define_parser(parser)
          parser.description = summary
          parser.add_argument('-c CONFIG', '--cloud-config=CONFIG',
                              :desc => '指定应用的云端数据配置文件',
                              :require => true) { |opt| @config = opt }
          parser.add_argument('--app-id',
                              :desc => '查询 app id 的值') { |opt| @app_id_flag = opt }
          parser.add_argument('--workspace-id',
                              :desc => '查询 workspace id 的值') { |opt| @workspace_id_flag = opt }
        end

        def run(argv)
          super(argv)
          app_info = AppInfoHelper.app_info_from_config(@config)
          if @app_id_flag
            assert(!app_info.app_id.nil?, '无法查询到 app id，检查云端数据配置文件的内容是否正确')
            UILogger.info(app_info.app_id)
          elsif @workspace_id_flag
            assert(!app_info.workspace_id.nil?, '无法查询到 workspace id，检查云端数据配置文件的内容是否正确')
            UILogger.info(app_info.workspace_id)
          end
        end
      end
    end
  end
end
