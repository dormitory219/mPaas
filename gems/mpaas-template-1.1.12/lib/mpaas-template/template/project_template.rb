# frozen_string_literal: true

# project_template.rb
# MpaasKit
#
# Created by quinn on 2019-01-10.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 工程模版数据结构
  #
  class ProjectTemplate < BaseTemplate
    def parse_ext_param(ext_param)
      @is_mpaas_project = ext_param.fetch(:mpaas_project, true)
    end

    def root_name
      GENERAL_LABEL_NAME[:prototype]
    end

    def edit
      UILogger.debug "编辑模版: #{@name}/#{root_name}"
      if @is_mpaas_project
        # 转换 mpaas 工程
        convert_mpaas_project
      else
        # 移除 mpaas main
        target_name = GENERAL_LABEL_NAME[:prototype]
        FileUtils.remove_entry(prototype_src_root + target_name + MPAAS_MAIN_FILE_NAME)
      end
      # 替换全部文件内容
      replace_file_content_labels(prototype_src_root.to_s + '/**/**/**/**')
      # 重命名文件
      rename_files
    end

    def save
      UILogger.debug "保存模版: #{@name}/#{root_name}"
      # 移动到目标目录下，已重命名
      FileUtils.mv(working_dir + basic_info.project_name, basic_info.project_path)
      # 初始化 git
      initialize_git_repo
    end

    # 保存后的工程文件
    #
    # @return [Array] xcodeproj 文件路径
    #
    def products
      @products ||= ["#{basic_info.project_name}.xcodeproj"]
    end

    # 工程的 src root
    #
    # @return [Pathname] 路径
    #
    def destination
      @destination ||= basic_info.project_path + basic_info.project_name
    end

    private

    # main.storyboard 文件路径
    MAIN_STORYBOARD_PATH = 'Base.lproj/Main.storyboard'
    # main.storyboard info.plist 文件中的 key
    MAIN_STORYBOARD_INFO_PLIST_KEY = 'UIMainStoryboardFile'
    # mpaas main 文件名
    MPAAS_MAIN_FILE_NAME = 'mpaas-main.m'
    # 标准 main 文件名
    STANDARD_MAIN_FILE_NAME = 'main.m'
    # 标准 AppDelegate 文件名
    APP_DELEGATE_FILE_NAME = 'AppDelegate'

    # 转换成 mpaas 工程
    #
    def convert_mpaas_project
      UILogger.info '转换 mpaas 框架工程'
      # 删除 main.storyboard 文件
      remove_main_storyboard
      # 替换 mpaas main 文件
      replace_mpaas_main
      # 删除 app delegate 文件
      remove_app_delegate
    end

    # 删除 main.storyboard 文件
    #
    def remove_main_storyboard
      UILogger.debug '移除 Main.storyboard'
      # 模版中的 target 名称，未重命名
      target_name = GENERAL_LABEL_NAME[:prototype]
      # 去除 info.plist 中的配置
      info_plist = XcodeHelper.search_info_plist_path(prototype_xcodeproj_path, target_name)
      PlistAccessor.remove_entry!(info_plist, [MAIN_STORYBOARD_INFO_PLIST_KEY])
      # 移除 build phase 中 Main.storyboard 组
      storyboard = prototype_src_root + target_name + 'Resources' + MAIN_STORYBOARD_PATH
      storyboard_group_path = XcodeHelper.find_group_path(prototype_xcodeproj_path, storyboard)
      XcodeHelper.remove_build_phases_ref(prototype_xcodeproj_path, target_name,
                                          XcodeHelper::RESOURCES, storyboard_group_path)
      # 移除引用
      XcodeHelper.remove_file_reference(prototype_xcodeproj_path, storyboard)
      XcodeHelper.remove_group_reference(prototype_xcodeproj_path, storyboard_group_path)
      # 删除实体文件
      FileUtils.rm_r(storyboard)
    end

    # 替换 mpaas main 文件
    #
    def replace_mpaas_main
      UILogger.debug '替换 main 文件'
      target_name = GENERAL_LABEL_NAME[:prototype]
      main_path = prototype_src_root + target_name + STANDARD_MAIN_FILE_NAME
      mpaas_main_path = prototype_src_root + target_name + MPAAS_MAIN_FILE_NAME
      # 只有 main.m 添加到工程中，只替换实体文件即可
      FileUtils.rm(main_path)
      FileUtils.mv(mpaas_main_path, main_path)
    end

    # 去除 app delegate 文件
    #
    def remove_app_delegate
      UILogger.debug '移除 AppDelegate'
      target_name = GENERAL_LABEL_NAME[:prototype]
      app_delegate_h = prototype_src_root + target_name + 'Sources' + "#{GENERAL_LABEL_NAME[:prefix]}AppDelegate.h"
      app_delegate_m = prototype_src_root + target_name + 'Sources' + "#{GENERAL_LABEL_NAME[:prefix]}AppDelegate.m"
      # 移除 build phase source
      XcodeHelper.remove_build_phases_ref(prototype_xcodeproj_path, target_name, XcodeHelper::SOURCES, app_delegate_m)
      # 移除引用
      XcodeHelper.remove_file_reference(prototype_xcodeproj_path, app_delegate_h)
      XcodeHelper.remove_file_reference(prototype_xcodeproj_path, app_delegate_m)
      # 删除实体文件
      FileUtils.rm(app_delegate_h)
      FileUtils.rm(app_delegate_m)
    end

    # 重命名文件
    #
    def rename_files
      UILogger.debug '重命名文件'
      code_label_replacements = {
        GENERAL_LABEL_NAME[:prototype] => basic_info.project_name,
        GENERAL_LABEL_NAME[:prefix] => basic_info.class_prefix
      }
      project_label_replacements = {
        GENERAL_LABEL_NAME[:prototype] => basic_info.project_name
      }
      target_name = GENERAL_LABEL_NAME[:prototype]
      # 先重命名内层，再重命名外层
      # 重命名代码文件
      FileProcessor.rename_file!(code_label_replacements, code_pattern_files)
      # 重命名工程文件
      FileProcessor.rename_file!(project_label_replacements, prototype_xcodeproj_path)
      # 重命名上层目录
      FileProcessor.rename_file!(project_label_replacements, prototype_src_root + target_name)
      FileProcessor.rename_file!(project_label_replacements, prototype_src_root)
    end

    # 带模版名称和 prefix 的文件
    #
    def code_pattern_files
      target_name = GENERAL_LABEL_NAME[:prototype]
      # scheme file（xcode9 工程）
      # scheme_path = prototype_xcodeproj_path + xcshareddata/xcschemes/#{PROTOTYPE_LABEL_NAME}.xcscheme"
      # demo files
      demo_files = %W[#{GENERAL_LABEL_NAME[:prefix]}AppDelegate.h
                      #{GENERAL_LABEL_NAME[:prefix]}AppDelegate.m
                      #{GENERAL_LABEL_NAME[:prefix]}DemoViewController.h
                      #{GENERAL_LABEL_NAME[:prefix]}DemoViewController.m]
      demo_files.map! { |f| prototype_src_root + target_name + 'Sources' + f }
      # supporting files
      # "#{PROTOTYPE_LABEL_NAME}-Info.plist"
      supporting_files = %W[#{GENERAL_LABEL_NAME[:prototype]}-Prefix.pch
                            #{GENERAL_LABEL_NAME[:prototype]}.entitlements]
      supporting_files.map! { |f| prototype_src_root + target_name + f }
      (demo_files + supporting_files).map(&:to_s)
    end

    # 初始化 git
    #
    def initialize_git_repo
      Dir.chdir(destination) do
        `rm -rf .git`
        `git init`
        `git add -A`
      end
    end

    # 工程的原型 src root
    #
    # @return 路径（Pathname 类型）
    #
    def prototype_src_root
      working_dir + root_name
    end

    # xcode 原型工程文件路径
    #
    def prototype_xcodeproj_path
      prototype_src_root + "#{GENERAL_LABEL_NAME[:prototype]}.xcodeproj"
    end
  end
end
