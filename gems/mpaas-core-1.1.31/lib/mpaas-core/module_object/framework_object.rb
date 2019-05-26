# frozen_string_literal: true

# framework_object.rb
# MpaasKit
#
# Created by quinn on 2019-02-24.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 工程包对象
  #
  class FrameworkObject
    # 初始化
    #
    def initialize(framework_info)
      @name = framework_info.fetch('name')
      @version = framework_info.fetch('version')
      @public_headers = framework_info.fetch('headers')
      @resources = framework_info.fetch('resources')
      @dependency_names = framework_info.fetch('dependencies')
      @system_frameworks = framework_info.fetch('systemFrameworks', [])
      @system_libs = framework_info.fetch('systemLibraries', [])
      @dependencies = []
      @refers = []
    end

    attr_reader :name,              # 展示的名称
                :version,           # 版本
                :public_headers,    # 头文件
                :dependencies,      # 依赖的其它工程包
                :refers,            # 引用该工程包的模块
                :system_frameworks, # 依赖的系统 framework
                :system_libs        # 依赖的系统 lib

    # 添加引用模块
    #
    # @param [ModuleObject] mod 模块对象
    #
    def add_refer(mod)
      @refers << mod unless mod.nil?
    end

    # 实际的名称（带.framework）
    #
    # @return [String]
    #
    def real_name
      @name + '.framework'
    end

    # 初始化依赖
    #
    # @param &block 回调 block，依赖转换为 FrameworkObject
    #
    def dependencies_generator
      return unless block_given?
      @dependencies = @dependency_names.map { |dep| yield dep }.compact
    end

    # 递归查找所有的依赖
    #
    # @return [Array<FrameworkObject>]
    #
    def find_all_dependencies
      return [self] if @dependencies.empty?
      [self] + @dependencies.map(&:find_all_dependencies).flatten
    end

    # 本地仓库路径
    #
    # @return [Pathname]
    #
    def local_repo
      LocalPath.sdk_framework_install_dir + @name + @version
    end

    # 下载 sdk 文件
    #
    def download_frameworks
      # 目录存在且不为空
      return if local_installed?
      # 下载
      UILogger.debug("下载 SDK 到本地: #{real_name}, #{@version}")
      uri = MpaasEnv.sdk_uri(@name, @version)
      DownloadKit.download_file_and_select(uri, local_repo, 'Products/*.framework') do |success|
        raise "下载 SDK 失败，请检查网络: #{@name} #{@version}" unless success
      end
    end

    # 需要添加的头文件，按依赖顺序
    #
    # @return [Array<String >]
    #
    def header_files
      (@dependencies.map(&:header_files).flatten + @public_headers).uniq
    end

    # 工程包文件列表
    # 针对 AntUI，ScanCode 类似的库
    #
    # @return [Array<String>] 每个元素为工程包全路径
    #
    def framework_files
      Dir.glob(local_repo + '*.framework')
    end

    # 资源文件列表
    #
    # @return [Array<String>] 每个元素为资源文件的全路径
    #
    def resource_files
      @resources.map { |r| Dir.glob(local_repo + r) }.flatten
    end

    # 文件路径
    #
    # @return [Pathname]
    #
    def location
      local_repo + real_name
    end

    private

    # 本地已经安装
    #
    # @return [Bool]
    #
    def local_installed?
      Dir.exist?(local_repo) && Dir.entries(local_repo).count > 2
    end
  end
end
