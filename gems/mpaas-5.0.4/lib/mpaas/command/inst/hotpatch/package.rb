# frozen_string_literal: true

# package.rb
# MpaasKit
#
# Created by quinn on 2019-03-03.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class Command
    class Inst
      class Hotpatch
        # 生成 hotpatch 资源包
        #
        class Package < Hotpatch
          def summary
            '生成热修复资源包'
          end

          def define_parser(parser)
            parser.description = summary
            parser.add_argument('-i INPUT', '--input=INPUT',
                                :desc => '需要打包的脚本文件',
                                :require => true) { |opt| @script_file = opt }
            parser.add_argument('-o PATH', '--output=PATH',
                                :desc => '生成热修复包的输出路径',
                                :default => -> { FileUtils.pwd }) { |opt| @output_dir = opt }
            parser.add_argument('--app-secret=SECRET',
                                :require => true,
                                :desc => '应用的 app secret 值') { |opt| @app_secret = opt }
            parser.add_argument('-p PEM', '--private-pem=PEM',
                                :desc => '打包所用的 rsa 私钥文件（.pem 文件）') { |opt| @private_key = opt }
            parser.add_argument('--gen-key',
                                :desc => '是否需要自动生成 rsa 密钥') { |opt| @need_gen_key = opt }
          end

          def run(argv)
            super(argv)
            validation
            # 读取私钥文件，未指定私钥，使用自动生成
            private_key_file = @private_key
            private_key_file = generate_rsa_key if private_key_file.nil? && @need_gen_key
            assert(File.exist?(private_key_file), '指定的私钥文件不存在')
            # 导出资源包
            print_result_message(export_hotpatch_package(private_key_file, @app_secret),
                                 '生成热修复包成功', '生成热修复包失败', 20)
          end

          private

          # 导出热修复资源包
          #
          # @param [String] private_key_file
          # @param [String] app_secret
          # @return [Bool] 是否成功
          #
          def export_hotpatch_package(private_key_file, app_secret)
            hotpatch_cmd = [
              LocalPath.bin_dir + 'HotpatchCmd',
              '-f', 'pack',
              '-input', @script_file,
              '-pem', private_key_file,
              '-output', @output_dir + '/hotpatch.pkg',
              '-aes', app_secret
            ].join(' ')
            output, status = CommandExecutor.exec(hotpatch_cmd)
            UILogger.debug(output) unless status.success?
            # 生成 JSPackage
            make_package_dir
            status.success?
          end

          # 生成 JSPackage 目录
          #
          def make_package_dir
            product_dir = File.dirname(@script_file) + '/JSPackage'
            dest_dir = @output_dir + '/JSPackage'
            # 如果输出目录和脚本当前目录相同，就不必处理
            return if product_dir == dest_dir
            # 自动生成的热修复包在脚本所在路径下
            FileUtils.rm_r(dest_dir) if File.exist?(dest_dir)
            FileUtils.mv(product_dir, @output_dir) if File.exist?(product_dir)
          end

          # 校验参数
          #
          def validation
            assert(!@config.nil? || !@app_secret.nil?, '缺少 app secret')
            assert(!@private_key.nil? || @need_gen_key, '缺少私钥文件')
            assert(File.exist?(@script_file), '输入的脚本文件不存在')
          end

          # 生成 rsa 密钥
          #
          # @return [String] 私钥文件路径
          #
          def generate_rsa_key
            # 自动生成 rsa 密钥
            UILogger.info('自动生成 rsa 密钥')
            rsa_key = OpenSSL::PKey::RSA.new(2048)
            private_key = rsa_key.to_pem
            public_key = rsa_key.public_key.to_pem
            key_dir = Pathname.new(@output_dir) + 'RsaKeys'
            FileUtils.mkdir_p(key_dir)
            private_key_file = key_dir + 'rsa_private_key.pem'
            public_key_file = key_dir + 'rsa_public_key.pem'
            File.open(private_key_file, 'wb') { |f| f.write(private_key) }
            File.open(public_key_file, 'wb') { |f| f.write(public_key) }
            private_key_file
          end
        end
      end
    end
  end
end
