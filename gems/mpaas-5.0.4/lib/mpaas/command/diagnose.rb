# frozen_string_literal: true

# diagnose.rb
# MpaasKit
#
# Created by quinn on 2019-03-10.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class Command
    # 诊断工具
    #
    class Diagnose < Command
      def summary
        'mPaaS 诊断工具'
      end

      def define_parser(parser)
        parser.description = summary
      end
    end
  end
end
