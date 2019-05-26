# frozen_string_literal: true

# extra_action.rb
# MpaasKit
#
# Created by quinn on 2019-03-10.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class MpaasFramework
    # 附加操作
    #
    class ExtraAction
      include BasicInfo::Mixin

      def initialize(project)
        @project = project
        # 集成工程的附加操作
        @ext_integrate_handlers = [
          :crash_ext_handle
        ]
        # 移除工程的附加操作
        @ext_deintegrate_handlers = %i[
          crash_ext_handle
          pch_ext_handler
        ]
      end

      # 集成执行附加操作
      #
      # @param [String] target_name
      # @param [MpaasTargetInfo] target_info
      #
      def perform_after_integrate(target_name, target_info)
        UILogger.info('执行集成后的附加操作')
        @ext_integrate_handlers.each do |handle|
          method(handle).call(target_name, target_info.versions_by_module.keys)
        end
      end

      # 去除执行附加操作
      #
      # @param [String] target_name
      # @param [MpaasTargetInfo] target_info
      #
      def perform_after_deintegrate(target_name, target_info)
        UILogger.info('执行去除集成后的附加操作')
        @ext_deintegrate_handlers.each do |handle|
          method(handle).call(target_name, target_info.versions_by_module.keys)
        end
      end

      private

      # 闪退模块名称
      #
      # @return [String]
      #
      def crash_module_name
        ModuleConfig.module_name('APCrashReporter')
      end

      # 处理闪退模块附加操作
      #
      # @param [String] target_name
      # @param [Array] modules
      #
      def crash_ext_handle(target_name, modules)
        main_path = XcodeHelper.search_from_build_phase(@project.xcodeproj_path, target_name,
                                                        XcodeHelper::BuildPhaseName::SOURCES, 'main.m')
        return if main_path.nil?
        code_exist = File.read(main_path).include?(report_crash_code)
        module_exist = modules.include?(crash_module_name)
        if code_exist && !module_exist
          # 删除模块, 代码删除
          remove_crash_report_code(main_path, report_crash_code)
        elsif module_exist && !code_exist
          # 新增模块, 在main中插入代码
          insert_crash_report_code(main_path)
        end
      end

      # 删除闪退日志代码
      #
      # @param [String] main_path
      # @param [String] code
      #
      def remove_crash_report_code(main_path, code)
        UILogger.debug("删除 #{File.basename(main_path)} 中闪退日志上报代码")
        FileProcessor.global_replace_file_content!({ code + "\n" => '' }, main_path)
      end

      # 插入闪退日志代码
      #
      # @param [Pathname] main_path
      #
      def insert_crash_report_code(main_path)
        UILogger.debug("向 #{File.basename(main_path)} 中插入闪退日志上报代码")
        # 旧代码存在，升级为新代码，先移除旧的
        upgrade_code = File.read(main_path).include?(OLD_CRASH_CODE) && !basic_info.active_v4
        remove_crash_report_code(main_path, OLD_CRASH_CODE) if upgrade_code
        # 插入新的
        content = "\n" + ' ' * 4 + report_crash_code + "\n"
        FileProcessor.insert_file!(main_path.to_s, content) do |buffer|
          func_start = buffer.index(/\s*int\s+main\s*\(\s*int\s+argc\s*,\s*char\s*\*\s*argv\s*\[\s*\]\s*\).*/)
          next if func_start.nil?
          idx = buffer.index('{', func_start)
          idx + 1 unless idx.nil?
        end
      end

      # 闪退添加的代码
      #
      # @return [String]
      #
      def report_crash_code
        basic_info.active_v4 ? OLD_CRASH_CODE : NEW_CRASH_CODE
      end

      # 旧的闪退代码
      OLD_CRASH_CODE = 'enable_crash_reporter_service(); // USE MPAAS CRASH REPORTER'
      # 新的闪退代码
      NEW_CRASH_CODE = '[MPAnalysisHelper enableCrashReporterService]; // USE MPAAS CRASH REPORTER'

      # pch 文件附加处理
      #
      # @param [String] target_name
      # @param [Array] _modules
      #
      def pch_ext_handler(target_name, _modules)
        pch_file = XcodeHelper.search_build_setting_field(@project.xcodeproj_path, target_name,
                                                          XcodeHelper::BS_PREFIX_HEADER)
        return if pch_file.nil? || !File.exist?(pch_file)
        # 转换绝对路径
        path = Pathname.new(pch_file)
        path = @project.src_root + path unless path.absolute?
        # 找出所有 import 的头文件
        existing_headers = File.read(path).scan(%r{#import (["-<>\w\/.]+)\n}).flatten.uniq
        # 查找 mpaas header
        mpaas_header = existing_headers.find { |header| header.include?('mPaaS-Header') }
        return if mpaas_header.nil?
        # 存在，删除 header 引用
        UILogger.debug("删除 pch 文件中的头文件引用: #{mpaas_header}")
        replacements = { "#import \"#{mpaas_header}\"" => '' }
        FileProcessor.global_replace_file_content!(replacements, pch_file)
      end
    end
  end
end
