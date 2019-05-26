# frozen_string_literal: true

# update.rb
# MpaasKit
#
# Created by quinn on 2019-01-19.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class Command
    # 更新 mpaas kit
    #
    class Update < Command
      def summary
        '更新 mPaaS 命令行工具'
      end

      def define_parser(parser)
        parser.description = summary
      end

      def run(argv)
        super(argv)
        # 暂时升级为重新安装
        script_url = MpaasEnv.mpaas_kit_home_uri + '/install.sh'
        exec("sh -c \"$(curl -s #{script_url} )\"")
        # Dir.mktmpdir do |tmp_dir|
        #   # 下载
        #   # 检查是否需要更新
        #   UILogger.info '下载安装包'
        #   DownloadKit.download_file_with_progress(MpaasEnv.mpaas_kit_package_uri, tmp_dir, true)
        #   UILogger.info '检查安装版本'
        #   existing_versions = {
        #     :mpaas => Mpaas::VERSION,
        #     'mpaas-env' => Mpaas::ENV_VERSION,
        #     'mpaas-common' => Mpaas::ENV_VERSION,
        #     'mpaas-template' => Mpaas::TEMPLATE_VERSION,
        #     'mpaas-project' => Mpaas::PROJECT_VERSION,
        #     'mpaas-core' => Mpaas::CORE_VERSION,
        #     'mpaas-xcplugin' => Mpaas::XCPlugin::VERSION
        #   }
        #   Dir['./*.gem'].map do |entry|
        #     name, version = entry.scan(/(.+)-([0-9]+\.[0-9]+\.[0-9]+)\.gem/).flatten
        #     existing_versions[name]
        #   end
        # end
      end
    end
  end
end
