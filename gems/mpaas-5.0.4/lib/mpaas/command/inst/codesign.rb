# frozen_string_literal: true

# codesign.rb
# workspace
#
# Created by quinn on 2019-03-31.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class Command
    class Inst
      # mPaaS 重签名
      #
      class Codesign < Inst
        def summary
          '重签名ipa包'
        end

        def define_parser(parser)
          parser.description = summary
          parser.add_argument('-i FILE', '--input=FILE',
                              :require => true,
                              :desc => '需要重签名的原始 ipa 文件') { |opt| @input_ipa = opt }
          parser.add_argument('-e CER', '--existing=CER',
                              :require => true,
                              :desc => '打包的证书名称') { |opt| @existing_cer = opt }
          parser.add_argument('-c IDENTIFIER', '--cer-id=IDENTIFIER',
                              :require => true,
                              :desc => '重签名使用的新证书 ID') { |opt| @cer_id = opt }
          parser.add_argument('-p PROFILE', '--profile=PROFILE',
                              :require => true,
                              :desc => '新的证书对应的 .mobileprovision 文件') { |opt| @profile = opt }
          parser.add_argument('-o PATH', '--output',
                              :desc => '重签名后的ipa包输出目录',
                              :default => -> { FileUtils.pwd }) { |opt| @output_dir = opt }
        end

        def run(argv)
          super(argv)
          assert(Pathname.new(@input_ipa).extname == '.ipa', '输入的ipa文件格式不正确')
          Dir.mktmpdir do |tmp_dir|
            # 解压 ipa 到临时目录
            UILogger.debug('解压 ipa')
            CommandExecutor.exec("unzip -o #{@input_ipa} -d #{tmp_dir}")
            # 提取 .app 文件名称
            app_file_path = extract_app_path(tmp_dir)
            # 删除签名文件
            remove_old_sign_files(app_file_path)
            # 生成 ipa
            package_ipa(tmp_dir, app_file_path)
          end
        end

        private

        # 打包生成 ipa
        #
        # @param [String] working_dir
        # @param [String] app_file_path
        #
        def package_ipa(working_dir, app_file_path)
          # 复制新的描述文件
          FileUtils.cp(@profile, app_file_path + '/embedded.mobileprovision')
          # 生成 entitlement
          output_dir = working_dir + '/output'
          FileUtils.mkdir_p(output_dir)
          entitlement = generate_entitlement(app_file_path, output_dir)
          # 解锁钥匙串
          CommandExecutor.exec('security unlock-keychain -p "密码" ~/Library/Keychains/login.keychain')
          # 重签名
          UILogger.info('重签名 app 文件')
          cmd = "codesign -f -s \"#{@existing_cer}\" --entitlements #{entitlement} #{app_file_path}"
          _, status = CommandExecutor.exec(cmd)
          raise '重签名失败' unless status.success?
          # 压缩成 ipa
          ipa_file_path = output_dir + '/' + File.basename(@input_ipa)
          UILogger.info("打包生成 ipa: #{ipa_file_path}")
          Dir.chdir(working_dir) { CommandExecutor.exec("zip -r #{ipa_file_path} Payload") }
          # 将 ipa 拷贝到输出目录
          FileUtils.cp_r(ipa_file_path, @output_dir)
        end

        # 生成 entitlement 文件
        #
        # @param [String] app_file_path
        # @param [String] output_dir
        #
        def generate_entitlement(app_file_path, output_dir)
          UILogger.info('生成 entitlement 文件')
          info_plist = app_file_path + '/Info.plist'
          bundle_id = PlistAccessor.fetch_entry(info_plist, ['CFBundleIdentifier'])
          template = TemplatesFactory.load_template(:entitlement,
                                                    :bundle_id => bundle_id, :user_id => @cer_id)
          template.edit
          template.save(output_dir)
          output_dir + '/' + template.products.shift
        ensure
          template&.close
        end

        # 移除旧的签名文件
        #
        # @param [String] app_file_path
        #
        def remove_old_sign_files(app_file_path)
          UILogger.debug('移除原有签名')
          FileUtils.remove_entry(app_file_path + '/embedded.mobileprovision')
          FileUtils.remove_entry(app_file_path + '/_CodeSignature')
        end

        # 提取 .app 文件路径和名称
        #
        # @param [String] working_dir
        # @return [Array] 第一个元素为路径，第二个元素为名称
        # e.g. ['/path/to/xxx.app', 'xxx']
        #
        def extract_app_path(working_dir)
          app_file, = CommandExecutor.exec("ls #{working_dir + '/Payload'}")
          app_file_path = working_dir + '/Payload/' + app_file
          app_name = File.basename(app_file_path, '.app')
          info_plist = app_file_path + '/Info.plist'
          CommandExecutor.exec("plutil -convert xml1 #{info_plist}", false)
          bundle_name = PlistAccessor.fetch_entry(info_plist, ['CFBundleName'])
          UILogger.debug("提取应用名称: #{app_name} - #{bundle_name}")
          return app_file_path if app_name == bundle_name
          FileUtils.mv(app_file_path + '/' + app_name, app_file_path + '/' + bundle_name)
          FileUtils.mv(app_file_path, File.dirname(app_file_path) + '/' + bundle_name + '.app')
          File.dirname(app_file_path) + '/' + bundle_name + '.app'
        end
      end
    end
  end
end
