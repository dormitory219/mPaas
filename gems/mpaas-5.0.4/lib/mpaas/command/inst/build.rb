# frozen_string_literal: true

# build.rb
# workspace
#
# Created by quinn on 2019-03-31.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class Command
    class Inst
      # mPaaS 打包
      #
      class Build < Inst
        def summary
          '打包命令'
        end

        def define_parser(parser)
          parser.description = summary
          parser.add_argument('-p PARAM', '--param=PARAM',
                              :require => true,
                              :desc => '打包的输出格式，默认 ipa 格式') { |opt| @param = opt }
        end

        def run(argv)
          super(argv)
          CommandExecutor.exec("sh #{LocalPath.bin_dir + 'mpaas_build.sh'} " + @param.tr(',', ' '))
        end
      end
    end
  end
end
