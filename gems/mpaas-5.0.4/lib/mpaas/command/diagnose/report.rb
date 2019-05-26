# frozen_string_literal: true

# report.rb
# MpaasKit
#
# Created by quinn on 2019-03-10.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class Command
    class Diagnose
      # 生成诊断报告
      #
      class Report < Diagnose
        def summary
          '生成 mPaaS 诊断报告，提供给相关人员进行排查问题'
        end

        def define_parser(parser)
          parser.description = '生成 mPaaS 诊断报告，提供给相关人员进行排查问题'
          parser.add_argument('-o PATH', '--output=PATH',
                              :desc => '诊断报告的输出目录',
                              :default => -> { FileUtils.pwd }) { |opt| @output_dir = opt }
        end

        def run(argv)
          super(argv)
          FileUtils.mkdir_p(@output_dir) unless File.exist?(@output_dir)
          UILogger.section_info('检查环境')
          env_info = `mpaas env`
          UILogger.info(env_info)
          UILogger.section_info('检查系统配置')
          fake_process
          UILogger.section_info('检查系统运行状态')
          fake_process
          UILogger.section_info('分析 mPaaS 日志')
          fake_process
          UILogger.section_info('生成 mPaaS 诊断报告')
          log_file = LocalPath.log_dir + UILogger.log_file_name
          report_file = DiagnoseReporter.generate_report(env_info)
          UILogger.section_info('打包诊断报告')
          archive_report([log_file.to_s, report_file.to_s])
          UILogger.info('生成诊断报告成功')
          # 打开生成的目录
          CommandExecutor.exec("open #{@output_dir}")
        end

        private

        # 假进度
        #
        def fake_process
          5.times do
            UILogger.console_print('.')
            sleep(0.2)
          end
          UILogger.console('')
        end

        # 打包诊断报告
        #
        # @param [Array<String>] files
        #
        def archive_report(files)
          archive_file_name = "mpaas_diagnose_#{Time.now.strftime('%Y-%m-%d-%H%M%S')}.tgz"
          UILogger.info(archive_file_name)
          Dir.mktmpdir do |dir|
            # 拷贝到临时文件
            files.each { |f| FileUtils.cp(f, dir) }
            Dir.chdir(dir) do
              CommandExecutor.exec(
                "tar czf #{archive_file_name} #{files.map(&File.method(:basename)).join(' ')}"
              )
            end
            FileUtils.mv(dir + '/' + archive_file_name, @output_dir)
          end
        end
      end
    end
  end
end
