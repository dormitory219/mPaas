# frozen_string_literal: true

# sign.rb
# MpaasKit
#
# Created by quinn on 2019-03-04.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class Command
    class Inst
      class Hotpatch
        # 热修复包签名
        #
        class Sign < Hotpatch
          def summary
            '提取热修复包的签名'
          end

          def define_parser(parser)
            parser.description = summary
            parser.add_argument('-i INPUT', '--input=INPUT',
                                :desc => '生成热修复资源包对应的 rsa 公钥（.pem 文件）',
                                :require => true) { |opt| @public_key = opt }
            parser.add_argument('-o PATH', '--output=PATH',
                                :desc => '签名文件的输出路径',
                                :default => -> { FileUtils.pwd }) { |opt| @output = opt }
            parser.add_argument('-p PEM', '--private-pem=PEM',
                                :desc => '生成热修复资源包对应的 rsa 私钥（.pem 文件）',
                                :require => true) { |opt| @private_key = opt }
          end

          def run(argv)
            super(argv)
            validation
            hotpatch_cmd = [
              LocalPath.bin_dir + 'HotpatchCmd',
              '-f', 'sign',
              '-input', @public_key,
              '-pem', @private_key,
              '-output', @output
            ].join(' ')
            output, status = CommandExecutor.exec(hotpatch_cmd)
            print_result_message(status.success?, output, '获取热修复包签名失败', 21)
          end

          private

          # 校验参数
          #
          def validation
            assert(File.exist?(@public_key), '输入的公钥文件不存在')
            assert(File.exist?(@private_key), '输入的私钥文件不存在')
          end
        end
      end
    end
  end
end
