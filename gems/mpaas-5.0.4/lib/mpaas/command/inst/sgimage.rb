# frozen_string_literal: true

# sgimage.rb
# MpaasKit
#
# Created by quinn on 2019-03-04.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class Command
    class Inst
      # 无线保镖图片
      #
      class Sgimage < Inst
        def summary
          '生成无线保镖图片'
        end

        def define_parser(parser)
          parser.description = summary
          parser.add_argument('-c CONFIG', '--cloud-config=CONFIG',
                              :desc => '应用的云端数据配置文件',
                              :require => true) { |opt| @config = opt }
          parser.add_argument('-V VERSION', '--jpg-version=VERSION',
                              :desc => '生成无线保镖图片的版本（默认 V5版本）',
                              :default => -> { '5' }) { |opt| @jpg_version = opt }
          parser.add_argument('--app-secret=SECRET',
                              :require => true,
                              :desc => '应用的 app secret 值') { |opt| @app_secret = opt }
          parser.add_argument('-o OUTPUT', '--output=OUTPUT',
                              :desc => '无线保镖图片的输出路径',
                              :default => -> { FileUtils.pwd }) { |opt| @output_dir = opt }
        end

        def run(argv)
          super(argv)
          print_result_message(SGImageGenerator.output_image_file(@config, @jpg_version, @output_dir, @app_secret),
                               '生成无线保镖图片成功', '生成无线保镖图片失败', 22)
        end
      end
    end
  end
end
