# frozen_string_literal: true

# plugins.rb
# MpaasKit
#
# Created by quinn on 2019-01-16.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class Command
    class Xcode
      # Xcode 插件相关
      #
      class Plugins < Xcode
        def summary
          'mpaas 的 Xcode 插件相关命令'
        end

        def define_parser(parser)
          parser.description = summary
        end
      end
    end
  end
end
