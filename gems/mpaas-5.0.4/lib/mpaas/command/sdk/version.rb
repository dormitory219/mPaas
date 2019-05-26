# frozen_string_literal: true

# version.rb
# MpaasKit
#
# Created by quinn on 2019-01-16.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class Command
    class Sdk < Command
      # 基线版本
      #
      class Version < Sdk
        def summary
          '查询基线版本'
        end

        def define_parser(parser)
          parser.description = summary
          parser.add_argument('-l', '--list',
                              :desc => '支持的所有基线版本列表') { |opt| @show_list = opt }
          parser.add_argument('--former=VERSION',
                              :desc => '获取旧基线的最新版本') { |opt| @former = opt }
        end

        def run(argv)
          super(argv)
          baseline_manager = BaselineManager.new
          baseline_manager.check_new_feature(@former)
          if !@former.nil? && @show_list
            baseline_manager.supported_versions.each(&UILogger.method(:info))
          else
            baseline_manager.check_for_updates
            UILogger.info(baseline_manager.version)
          end
        end
      end
    end
  end
end
