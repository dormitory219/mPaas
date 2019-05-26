# frozen_string_literal: true

# backup.rb
# MpaasKit
#
# Created by quinn on 2019-01-24.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 备份工具
  #
  class BackupKit
    class << self
      def backup(project)
        tmp_dir = Dir.mktmpdir
        backup_dir = tmp_dir + '/mpaas-bak'
        back_files = search_back_files(project)
        begin
          UILogger.debug('备份原始工程')
          # 工程文件，pch 文件，MPaaS 目录
          FileUtils.mkdir_p(backup_dir)
          back_files.each { |path| FileUtils.cp_r(path, backup_dir) }
          yield if block_given?
        rescue StandardError
          UILogger.debug('执行操作异常，恢复备份工程')
          # 还原
          recover_back_files(backup_dir, back_files)
          raise
        ensure
          FileUtils.remove_entry(tmp_dir, true)
        end
      end

      # 备份的文件
      # 包括 xcodeproj 文件，pch 文件，MPaaS 目录
      #
      # @param [XCProjectObject] project
      # @return [Array]
      #
      def search_back_files(project)
        files = [project.xcodeproj_path]
        pch_path = XcodeHelper.search_pch_path(project.xcodeproj_path, project.active_target)
        files << pch_path unless pch_path.directory?
        files << File.dirname(project.mpaas_file.file_path) if project.mpaas_file.exist?
        files
      end

      # 还原备份文件
      #
      # @param [备份目录] backup_dir
      # @param [备份的文件] back_files
      #
      def recover_back_files(backup_dir, back_files)
        back_files.each do |path|
          FileUtils.remove_entry(path, true)
          FileUtils.cp_r(backup_dir + '/' + File.basename(path), path)
        end
      rescue StandardError => e
        UILogger.error(e.message)
      end
    end
  end
end
