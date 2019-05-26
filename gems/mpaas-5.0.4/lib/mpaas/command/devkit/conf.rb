# frozen_string_literal: true

# conf.rb
# MpaasKit
#
# Created by quinn on 2019-03-11.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class Command
    class Devkit
      # 配置工具
      #
      class Conf < Devkit
        def summary
          '修改开发配置'
        end

        def define_parser(parser)
          parser.description = summary + '（需要管理员权限来执行）'
          parser.add_argument('--set-env=ENV',
                              :desc => '设置当前开发环境变量（dev, prod）') { |opt| @env = opt }
          parser.add_argument('--show-env',
                              :desc => '显示当前开发环境') { |opt| @show = opt }
        end

        def run(argv)
          super(argv)
          user_authentication do
            if @show
              UILogger.info(MpaasEnv.current_env)
            elsif @env
              UILogger.info("设置当前开发环境为: #{@env}")
              MpaasEnv.setup_config(@env.to_s)
            end
          end
        end
      end
    end
  end
end
