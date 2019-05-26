# frozen_string_literal: true

# check.rb
# MpaasKit
#
# Created by quinn on 2019-03-10.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class Command
    class Sdk
      # 基线相关
      #
      class Check < Sdk
        def summary
          'mPaaS 组件 SDK 的基线工具集'
        end

        def define_parser(parser)
          parser.description = summary
          parser.add_argument('--upgrade-min-version',
                              :desc => '查看支持升级基线的最低版本',
                              &proc { |opt| @support_min_version = opt })
        end

        def run(argv)
          super(argv)
          # 查看支持基线升级模块的最低版本
          UILogger.info(BaselineManager.new.new_feature_min_version) if @support_min_version
        end
      end
    end
  end
end
