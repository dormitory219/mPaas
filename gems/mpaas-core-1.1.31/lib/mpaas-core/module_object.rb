# frozen_string_literal: true

# module_object.rb
# MpaasKit
#
# Created by quinn on 2019-01-12.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 模块对象
  #
  class ModuleObject
    # 初始化
    #
    # @param module_info_hash 模块信息字典
    #
    def initialize(module_info_hash)
      @name = module_info_hash.fetch('name')
      @title = module_info_hash.fetch('title')
      @description = module_info_hash.fetch('description')
      @release_note = module_info_hash.fetch('releaseNote')
      @framework_name_list = module_info_hash.fetch('frameworks')
      @framework_obj_list = []
      @baseline = nil
    end

    attr_accessor :baseline # 模块所在的基线
    attr_reader :name,                # 名称
                :title,               # 标题
                :description,         # 描述
                :release_note,        # release note
                :framework_obj_list   # 包含的工程包列表

    # 关联的模块数组
    # 不包括自身
    #
    # @return [Array<ModuleObject>]
    #
    def related_modules
      all_framework_obj.flat_map(&:refers).compact.uniq - [self]
    end

    # 设置模块包含的工程包
    #
    # @param &block 回调，将工程包名称转换成 FrameworkObject
    #
    def frameworks_generator
      return unless block_given?
      @framework_obj_list = @framework_name_list.map do |name|
        framework_obj = yield name
        UILogger.warning("找不到对应的配置: #{name}.framework") if framework_obj.nil?
        # 设置引用
        framework_obj&.add_refer(self)
        framework_obj
      end.compact
    end

    # 下载模块文件
    #
    def download_files
      # 下载所有的依赖模块
      all_framework_obj.each(&:download_frameworks)
      FileUtils.mkdir_p(repo_dir)
      # 建立软连接
      all_framework_obj.each do |fw_obj|
        FileUtils.remove_entry(repo_dir + fw_obj.name) if (repo_dir + fw_obj.name).exist?
        FileUtils.symlink(fw_obj.local_repo, repo_dir + fw_obj.name)
      end
    end

    # 是否完全包含另一个模块
    # 模块所有依赖的工程包 为 当前模块所有依赖工程包的子集
    #
    # @param [ModuleObject] mod
    # @return [Bool]
    #
    def include?(mod)
      all_frameworks = all_framework_obj.map(&:name)
      cmp_frameworks = mod.framework_obj_list.map(&:find_all_dependencies).flatten.uniq.map(&:name)
      (all_frameworks & cmp_frameworks).sort == cmp_frameworks.sort
    end

    # 是否为 component 模块，兼容 v4
    #
    def component?
      true
    end

    # 递归依赖模块，兼容 v4
    #
    def find_dependency_module(_exist_modules)
      []
    end

    # 版本号，兼容 v4
    #
    def version
      nil
    end

    # 头文件
    #
    # @return 引入头文件数组
    #
    def header_files
      @framework_obj_list.map(&:header_files).flatten
    end

    # 分类文件的目录列表
    #
    # @return [Array, nil]
    #
    def category_dir_list
      # 工程包名命中白名单中，返回该名称
      ModuleConfig.category_white_list.select { |name| all_framework_obj.map(&:name).include?(name) }
    end

    # 模块依赖的所有工程包名称列表
    #
    # @return [Array<String>]
    #
    def frameworks
      all_framework_obj.flat_map(&:framework_files).compact.map(&File.method(:basename))
    end

    # 模块依赖的所有工程包位置列表
    #
    # @return [Array<String>]
    #
    def framework_locations
      all_framework_obj.flat_map(&:framework_files).map(&Pathname.method(:new))
    end

    # 所有工程包的版本信息
    # （包括依赖的工程包）
    #
    # @return [Hash]
    #         e.g. { "Framework1": "1.0.0", "Framework2": "1.0.0" }
    def frameworks_version_info
      all_framework_obj.map { |fw_obj| [fw_obj.name, fw_obj.version] }.to_h
    end

    # 模块包含的所有资源文件名列表
    #
    # @return [Array<String>]
    #
    def resources
      all_framework_obj.flat_map(&:resource_files).compact.map(&File.method(:basename))
    end

    # 模块包含的资源文件路径列表
    #
    # @return [Array<String>]
    #
    def resource_locations
      all_framework_obj.flat_map(&:resource_files).map(&Pathname.method(:new))
    end

    # 系统库 framework
    #
    # @return [Array<String>]
    #
    def system_frameworks
      all_modules = (related_modules.select(&method(:include?)) + [self]).map(&:name)
      sys_frameworks = all_framework_obj.flat_map(&:system_frameworks).map { |n| n + '.framework' }
      (sys_frameworks + all_modules.flat_map(&ModuleConfig.method(:framework_for_name))).uniq
    end

    # 系统库 lib
    #
    # @return [Array<String>]
    #
    def system_libraries
      all_modules = (related_modules.select(&method(:include?)) + [self]).map(&:name)
      sys_libs = all_framework_obj.flat_map(&:system_libs).map { |n| n + '.framework' }
      (sys_libs + all_modules.flat_map(&ModuleConfig.method(:library_for_name))).uniq
    end

    # 模块是否有更新
    #
    # @param [ModuleObject] module_obj
    # @return [Bool]
    #
    def module_updated?(module_obj)
      # 工程包相同，工程包的版本相同
      @name == module_obj.name && frameworks_version_info == module_obj.frameworks_version_info
    end

    # 查找对应的 framework 对象
    #
    # @param [String] fw_name
    # @return [FrameworkObject]
    #
    def find_framework_obj(fw_name)
      all_framework_obj.find { |f| f.name == fw_name }
    end

    private

    # 所有依赖的工程包
    #
    # @return [Array<FrameworkObj>]
    #
    def all_framework_obj
      @framework_obj_list.map(&:find_all_dependencies).flatten.uniq
    end

    # 模块的目录
    #
    # @return [Pathname]
    #
    def repo_dir
      LocalPath.sdk_module_install_dir + @name + @baseline
    end
  end
end
