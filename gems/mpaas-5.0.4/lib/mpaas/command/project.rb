# frozen_string_literal: true

# project.rb
# MpaasKit
#
# Created by quinn on 2019-01-14.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class Command
    # 工程相关命令
    #
    class Project < Command
      def summary
        'mpaas 工程框架相关的命令'
      end

      def define_parser(parser)
        parser.description = summary
      end

      protected

      # 校验参数
      #
      def validation; end

      # 格式化模块列表参数
      #
      # @param [Array<String>] modules
      #        e.g. [name1, name2, ...]
      #             [name1:version, name2:version, ...]
      # @return [Array<String, Array>] 转换后的模块列表
      #
      def format_modules_argument(modules)
        modules.map do |pair|
          fields = pair.split(':')
          fields.count == 1 ? fields[0] : fields
        end
      end
    end
  end
end
