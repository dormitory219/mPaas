# frozen_string_literal: true

# diagnose_reporter.rb
# MpaasKit
#
# Created by quinn on 2019-03-10.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 诊断报告
  #
  class DiagnoseReporter
    class << self
      # 生成诊断报告
      #
      # @param [String,Array] env_info
      # @return [Pathname] 生成报告的路径
      #
      def generate_report(env_info)
        report_name = "mpaas_report_#{Time.now.strftime('%Y-%m-%d-%H%M%S')}.diag"
        report_content = assemble_report_content(env_info)
        FileUtils.mkdir_p(LocalPath.report_dir) unless File.exist?(LocalPath.report_dir)
        File.open(LocalPath.report_dir + report_name, 'wb') { |f| f.write(report_content) }
        LocalPath.report_dir + report_name
      end

      private

      # 报告内容
      #
      # @param [String] env_info
      # @return [String]
      #
      def assemble_report_content(env_info)
        [
          env_info,
          '',
          'Installed Xcode Apps:',
          SystemInfo.installed_xcode_info,
          '',
          'System Profiles:',
          SystemInfo.system_profiles,
          '',
          'System Running Status:',
          SystemInfo.mac_os_status,
          '',
          'Process Running Status:',
          SystemInfo.xcode_process_info,
          ''
        ].flatten.join("\n")
      end
    end
  end
end
