# frozen_string_literal: true

# module_object_old.rb
# MpaasKit
#
# Created by quinn on 2019-02-24.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 模块对象，4.0版本
  #
  class ModuleObjectOld
    # 初始化
    #
    # @param module_info_hash 模块信息字典
    #
    def initialize(module_info_hash)
      @name = module_info_hash.fetch(:name)
      @version = module_info_hash.fetch(:version)
      @group = module_info_hash.fetch(:group)
      @title = module_info_hash.fetch(:title)
      @description = module_info_hash.fetch(:description)
      @release_note = module_info_hash.fetch(:releaseNote)
      @framework_list = []
      @refers = []
    end

    attr_accessor :dependencies,  # 依赖的模块数组
                  :baseline       # 所在基线（fake）
    attr_reader :name,          # 模块名
                :version,       # 版本号
                :title,         # 标题
                :description,   # 描述
                :release_note,  # release note
                :refers         # 依赖引用

    # 添加引用
    #
    # @param [ModuleObject] mod
    #
    def add_refer(mod)
      @refers << mod unless mod.nil?
    end

    # 是否为 component 模块
    #
    # @return [Bool]
    #
    def component?
      @group == 'component'
    end

    # 递归依赖模块
    #
    # @param exist_modules 已经添加的模块
    # @return [Array<ModuleObject>] 所有依赖的模块
    #
    def find_dependency_module(exist_modules)
      modules = []
      @dependencies.each { |m| modules << m unless exist_modules.include?(m) }
      modules.each { |m| modules += m.find_dependency_module(modules + exist_modules) }
      modules
    end

    # 包括自己的所有引用模块
    #
    # @return [Array<ModuleObject>]
    #
    def find_all_refers
      return [self] if refers.empty?
      refers.flat_map(&:find_all_refers).uniq + [self]
    end

    # 本地缓存的仓库目录
    #
    # e.g. 单 framework 文件存放在 /Users/Shared/.mpaaskit_sdk/name/version/name.framework
    #      多 framework 文件存放在 /Users/Shared/.mpaaskit_sdk/name/version/name/name.framework
    #
    def local_repo
      single_framework_repo = LocalPath.sdk_home_dir + @name + @version
      multi_framework_repo = LocalPath.sdk_home_dir + @name + @version + @name
      multi_frameworks? ? multi_framework_repo : single_framework_repo
    end

    # 是否为多 framework 模块
    # Info.json 存在就是多 framework 模块
    #
    def multi_frameworks?
      File.exist?(LocalPath.sdk_home_dir + @name + @version + @name + 'Info.json')
    end

    # 工程包版本信息，兼容 v5
    #
    def frameworks_version_info
      {}
    end

    # 本地是否安装
    #
    # @return [Bool]
    #
    def installed?
      Dir.exist?(LocalPath.sdk_home_dir + @name + @version)
    end

    # 是否包含另一个模块，兼容 v5
    # 不存在包含关系
    #
    # @param [ModuleObject] _mod
    # @return [Bool]
    #
    def include?(_mod)
      false
    end

    # 需要的分类文件目录
    # v4 返回自身模块名
    #
    # @return [Array]
    #
    def category_dir_list
      [@name]
    end

    # .framework 文件
    #
    def frameworks
      return [] unless installed?
      multi_frameworks? ? profile['frameworks'] : ["#{name}.framework"]
    end

    # framework 位置
    #
    # @return [Array]
    #
    def framework_locations
      frameworks.map { |name| local_repo + name }
    end

    # 资源文件
    #
    # @return [Array]
    #
    def resources
      @resources ||=
        if !installed?
          []
        elsif multi_frameworks?
          profile.fetch('resources', []).map { |path| path.split('/').last }
        else
          plist_path = local_repo + "#{@name}.framework" + 'Info.plist'
          # 转换plist为xml mode
          CommandExecutor.exec("plutil -convert xml1 #{plist_path}", false)
          PlistAccessor.fetch_entry(plist_path, ['Resources']) || []
        end
    end

    # 资源位置
    #
    # @return [Array]
    #
    def resource_locations
      resources.map(&method(:resource_location))
    end

    # 头文件
    #
    # @return 引入头文件数组
    #
    def header_files
      # 未安装直接返回空
      return [] unless installed?
      pre_headers = @dependencies.map(&:header_files).flatten
      return pre_headers if no_public_header?

      (pre_headers + (multi_frameworks? ? profile.fetch('headers', []) : public_headers)).uniq
    end

    # 系统 lib 库
    #
    # @return [Array<String>] lib 数组
    #
    def system_libraries
      installed? ? ModuleConfig.library_for_name(@name) : []
    end

    # 系统 framework 库
    #
    # @return [Array<String>] framework 数组
    #
    def system_frameworks
      installed? ? ModuleConfig.framework_for_name(@name) : []
    end

    # 模块是否有更新
    #
    # @param [ModuleObject] module_obj
    # @return [Bool]
    #
    def module_updated?(module_obj)
      @name == module_obj.name && @version != module_obj.version
    end

    private

    # 资源位置
    #
    # @param name 资源名称
    #
    def resource_location(name)
      return local_repo + "#{@name}.framework" + name unless multi_frameworks?
      # 多 framework
      path = profile.fetch('resources', []).find { |p| p.end_with?(name) }
      path.nil? ? nil : local_repo + path
    end

    # 模块的描述文件
    #
    def profile
      @profile ||= JSON.parse(File.read(local_repo + 'Info.json')) if multi_frameworks?
    end

    # 公开的头文件
    #
    # @return [Array] 数组
    #
    def public_headers
      Array({
        :APCrashReporter => "<#{@name}/DFCrashReport.h>",
        :APConfig => "<#{@name}/APConfigService.h>"
      }.fetch(@name.to_sym, "<#{@name}/#{@name}.h>"))
    end

    # 不需要引入头文件的模块
    #
    # @return 是否需要添加头文件 true/false
    #
    def no_public_header?
      ModuleConfig.public_header_black_list.include?(@name)
    end
  end
end
