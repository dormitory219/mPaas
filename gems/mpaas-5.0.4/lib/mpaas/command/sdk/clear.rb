# frozen_string_literal: true

# clear.rb
# MpaasKit
#
# Created by quinn on 2019-03-07.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class Command
    class Sdk
      # 清除缓存
      #
      class Clear < Sdk
        def summary
          '清空本地 mPaaS 的 SDK 缓存'
        end

        def define_parser(parser)
          parser.description = summary
        end

        def run(argv)
          super(argv)
          answer = InteractionAssistant.ask_with_answers('该操作不可恢复，确认删除吗?', %w[y n])
          FileUtils.rm_r(LocalPath.sdk_home_dir) if answer == 'y' && LocalPath.sdk_home_dir.exist?
        end
      end
    end
  end
end
