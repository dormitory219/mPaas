# frozen_string_literal: true

# baseline_manager.rb
# MpaasKit
#
# Created by quinn on 2019-01-11.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 管理本地和远程基线相关的 SDK 文件
  #
  class BaselineManager
    require_relative 'baseline_manager/baseline_version'
    require_relative 'baseline_manager/baseline_old'
    require_relative 'baseline_manager/baseline_local'

    def initialize
      @version = nil            # 最新基线版本
      @component_info = nil     # 最新基线的 component.json
      @latest_modules = []      # 最新基线的所有模块
      @latest_frameworks = []   # 最新基线的所有工程包
      @supported_versions = nil # 支持的基线列表
      @using_new_feature_checked = false # 是否已经检查了使用新特性
      @all_modules = {} # 不同基线的模块列表
    end

    # 校验新特性
    # [!!注意] 必须在调用时先校验新特性，决定使用 v4 还是 v5
    #
    # @param [String] baseline 校验的基线号
    #
    def check_new_feature(baseline)
      # 未配置最低版本，就使用 v4
      # 配置了最低版本，参数为空，使用新特性
      # 配置了最低版本，如果当前的版本比配置的最低版本高，使用新特性
      # false 为使用新特性
      basic_info.active_v4 = if new_feature_min_version.nil? || new_feature_min_version.empty?
                               true
                             elsif baseline.nil?
                               false
                             else
                               VersionCompare.compare(baseline).smaller_than?(new_feature_min_version)
                             end
      @using_new_feature_checked = true
    end

    # 获取全部的模块
    # [!!注意] 必须在调用前先执行一次校验 check_new_feature
    #
    # @param [String] baseline 基线版本号，nil 表示最新基线
    # @return [Array<ModuleObject>]
    #
    def fetch_all_modules(baseline = nil)
      return nil unless @using_new_feature_checked
      if baseline.nil?
        check_local_sdk(@latest_modules)
      else
        load_modules(baseline)
      end
    end

    # 根据模块和基线号，取对应的模块对象
    #
    # @param [String] name
    # @param [String] baseline
    # @return [ModuleObject,nil]
    #
    def fetch_module_obj(name, baseline = nil)
      baseline ||= @version
      module_obj = load_modules(baseline).find { |mod| mod.name == name }
      UILogger.warning("当前基线未找到对应模块: #{baseline} - #{name}") if module_obj.nil?
      check_local_sdk([module_obj]).first
    end

    # 获取模块信息
    # 选择的模块
    #
    # @param [Array] names 请求的模块名
    #        e.g. [name1, name2, ...] v5 结构
    #             [[name1, baseline1], [name2, baseline2], ...} v4结构
    # @param [String] baseline 基线版本
    # @return [Array<ModuleObject>] 模块对象数组
    #
    def fetch_module_info(names, baseline = nil)
      return nil unless @using_new_feature_checked
      return fetch_module_info_old(names) if basic_info.active_v4
      # 选取模块，检查本地是否存在，不存在就去下载
      check_local_sdk(select_install_modules(names, baseline || @version))
    end

    # 获取模块信息
    # 选择的模块及依赖该模块的模块
    #
    # @param [Array] names 请求的模块名
    #        e.g. [name1, name2, ...] v5 结构
    #             [[name1, baseline1], [name2, baseline2], ...} v4结构
    # @param [String] baseline 基线版本
    # @return [Array<ModuleObject>] 模块对象数组
    #
    def fetch_module_info_ref(names, baseline = nil)
      return nil unless @using_new_feature_checked
      return fetch_module_info_ref_old(names) if basic_info.active_v4
      fetch_module_info(names, baseline)
    end

    # 远程 SDK 信息
    #
    # @param [String] baseline
    # @return [Hash]
    # e.g. { name: xx, version: x.x.x, title: xx, description: xx,
    #        releaseNote: xx, dependencies: { xxx: x.x.x, ... } }
    #
    def remote_sdk_info(baseline)
      return nil unless @using_new_feature_checked
      return remote_sdk_info_old(baseline) if basic_info.active_v4
      # 新版需要取framework的版本
      component_info = load_component_info(baseline)
      frameworks = component_info['frameworks']
      component_info['modules'].map do |info|
        dependencies = info['frameworks'].map do |name|
          [name, frameworks.find { |f| f['name'] == name }.fetch('version')]
        end.to_h
        info.delete('frameworks')
        info.merge(:dependencies => dependencies, :version => baseline).map { |k, v| [k.to_sym, v] }.to_h
      end
    end

    private

    # 获取最新基线的所有模块
    #
    # @return [Array<ModuleObject>] 模块对象数组
    #
    def fetch_latest_modules
      if basic_info.active_v4
        check_sdk_old(@latest_modules)
      else
        check_local_sdk(@latest_modules)
      end
    end

    # 检查本地的 SDK 是否存在，不存在就去下载
    #
    # @param [Array] modules 检查的模块
    # @return [Array<ModuleObject>]
    #
    def check_local_sdk(modules)
      return check_sdk_old(modules) if basic_info.active_v4
      modules.each(&:download_files)
    end

    # 加载基线配置对应的工程包和模块
    #
    # @param [String] baseline_version
    # @return [Array] 模块对象数组
    #
    def load_modules(baseline_version)
      return load_modules_old(baseline_version) if basic_info.active_v4
      return @all_modules[baseline_version] if @all_modules.key?(baseline_version)
      # 加载模块信息
      UILogger.debug "解析所有配置的模块信息: #{baseline_version}"
      # 下载基线模块信息文件并读取
      component_info = load_component_info(baseline_version)
      # 生成工程包
      framework_obj_list = component_info['frameworks'].map(&FrameworkObject.method(:new))
      # 工程包设置依赖
      framework_obj_list.each do |fw_obj|
        fw_obj.dependencies_generator { |fw_name| framework_obj_list.find { |f| f.name == fw_name } }
      end
      # 生成模块
      module_obj_list = component_info['modules'].map(&ModuleObject.method(:new))
      module_obj_list.each { |mod| mod.baseline = baseline_version }
      # 添加工程包
      module_obj_list.each do |mod|
        mod.frameworks_generator { |fw_name| framework_obj_list.find { |f| f.name == fw_name } }
      end
      # 缓存模块
      @all_modules[baseline_version] = module_obj_list
      module_obj_list
    end

    # 读取 Component.json 信息
    #
    # @param version 基线版本
    # @return [Hash] 信息内容
    #
    def load_component_info(version)
      return load_component_info_old(version) if basic_info.active_v4
      # 读取 component
      local_component_file = baseline_dir + version + 'Component.json'
      download_uri = MpaasEnv.baseline_component_uri(version)
      # 最新基线版本必须下载，其它版本本地不存在才下载
      if version == @version || !local_component_file.exist?
        DownloadKit.download_file(download_uri, local_component_file, false) do |success|
          raise "下载基线 #{version} 配置失败，请检查网络" unless success
        end
      end
      JSON.parse(File.read(local_component_file))
    end

    # 选择安装的模块
    #
    # @param [Array] names 请求的模块名，如果不带版本默认最高版本
    #        e.g. [name1, name2, ...]
    # @param [String] baseline 基线版本号
    # @return [Array<ModuleObject>] 模块对象列表
    #
    def select_install_modules(names, baseline)
      modules = load_modules(baseline)
      # 添加所有的模块
      names.flat_map do |name|
        # 选取包含的模块一并添加
        main_module = modules.find { |m| m.name == name }
        if main_module.nil?
          UILogger.warning("基线 #{baseline} 中不包括该模块: #{name}")
          next
        end
        modules.select { |m| main_module&.include?(m) }
      end.compact.uniq
    end

    # 基线配置文件目录
    #
    # @return [Pathname] 路径
    #
    def baseline_dir
      LocalPath.home_dir + 'baseline'
    end
  end
end
