# frozen_string_literal: true

# app_template.rb
# MpaasKit
#
# Created by quinn on 2019-01-10.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 应用模版类
  #
  class AppTemplate < BaseTemplate
    def parse_ext_param(ext_param)
      @launcher_type = ext_param.fetch(:app_type)
      @xcodeproj_path = ext_param.fetch(:xcodeproj)
    end

    def root_name
      @launcher_type
    end

    def edit
      UILogger.debug "编辑模版: #{@name}/#{root_name}"
      # 替换文件内容标签，不替换前缀
      replace_file_content_labels((working_dir + root_name).to_s + '/**',
                                  :remove => [GENERAL_LABEL_NAME[:prefix]])
    end

    def save(dest_path = nil)
      UILogger.debug "保存模版: #{@name}/#{root_name}"
      launcher_dir = dest_path + 'Launcher'
      # 把模版保存到指定目录，重命名为 Launcher
      FileUtils.mv(working_dir + root_name, launcher_dir)
      # 添加文件引用
      add_file_reference(launcher_dir)
      # 添加 build phase
      add_build_phase(launcher_dir)
    end

    private

    # plist 文件
    APP_TEMPLATE_PLIST_NAME = 'MobileRuntime.plist'

    # 添加文件文件
    #
    # @param launcher_dir 添加的 launcher 目录
    #
    def add_file_reference(launcher_dir)
      launcher_dir = Pathname.new(launcher_dir)
      XcodeHelper.add_group_reference(@xcodeproj_path, launcher_dir)
      (Dir.entries(launcher_dir) - %w[. ..]).sort.each do |entry|
        XcodeHelper.add_file_reference(@xcodeproj_path, launcher_dir + entry)
      end
    end

    # 添加 build phase
    #
    # @param launcher_dir 添加的 launcher 目录
    #
    def add_build_phase(launcher_dir)
      launcher_dir = Pathname.new(launcher_dir)
      Dir.glob(launcher_dir.to_s + '/*.m').each do |entry|
        XcodeHelper.add_build_phases_ref(@xcodeproj_path, basic_info.active_target,
                                         XcodeHelper::SOURCES, entry)
      end
      Dir.glob(launcher_dir.to_s + '/*.plist').each do |entry|
        XcodeHelper.add_build_phases_ref(@xcodeproj_path, basic_info.active_target,
                                         XcodeHelper::RESOURCES, entry)
      end
    end
  end
end
