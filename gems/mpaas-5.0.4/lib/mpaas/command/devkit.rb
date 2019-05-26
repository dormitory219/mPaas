# frozen_string_literal: true

# devkit.rb
# MpaasKit
#
# Created by quinn on 2019-02-23.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class Command
    # 开发工具集
    #
    class Devkit < Command
      def summary
        'mpaas kit 开发工具（只有管理员有权限执行）'
      end

      def define_parser(parser)
        parser.description = summary
      end

      protected

      # 身份认证
      #
      # @param &block 回调 block，验证成功执行
      #
      def user_authentication
        if Authenticator.login_as_admin
          UILogger.info('身份验证成功')
          yield if block_given?
        else
          UILogger.error('管理员身份验证失败')
        end
      end
    end
  end
end
