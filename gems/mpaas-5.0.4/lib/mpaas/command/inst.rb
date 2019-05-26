# frozen_string_literal: true

# inst.rb
# MpaasKit
#
# Created by quinn on 2019-03-03.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class Command
    # 基础工具集，包括无线保镖图片生成，hotpatch 包生成等
    class Inst < Command
      def summary
        '基础工具集'
      end

      def define_parser(parser)
        parser.description = summary
      end
    end
  end
end
