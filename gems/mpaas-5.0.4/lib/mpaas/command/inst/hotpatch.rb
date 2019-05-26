# frozen_string_literal: true

# hotpatch.rb
# MpaasKit
#
# Created by quinn on 2019-03-03.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class Command
    class Inst
      # 热修复包
      #
      class Hotpatch < Inst
        def summary
          '热修复包相关工具'
        end

        def define_parser(parser)
          parser.description = summary
        end
      end
    end
  end
end
