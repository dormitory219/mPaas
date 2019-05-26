# frozen_string_literal: true

# baseline_old.rb
# MpaasKit
#
# Created by quinn on 2019-02-24.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 基线管理，4.0版本逻辑
  #
  class BaselineManager
    private

    # 检查基线更新
    #
    def check_for_updates_old
      UILogger.debug '检查基线版本更新'
      # 取最新版本号
      @version = DownloadKit.download_string(MpaasEnv.baseline_version_uri)
      raise '请求基线版本失败，请检查网络' if @version.nil?
      # 获取成功
      UILogger.debug("获取最新 SDK 信息: #{@version}")
      # 加载最新基线的所有模块
      @latest_modules = load_modules_old(@version)
    end

    # 获取模块信息
    # 选择的模块及该模块依赖的模块
    #
    # @param [Array] baseline_by_name 请求的模块名和基线信息
    #                e.g. [[name1, baseline1], [name2, baseline2], ...]
    # @return [Array<ModuleObject>] 模块对象数组
    #
    def fetch_module_info_old(baseline_by_name)
      # 选取模块
      install_modules = select_install_modules_old(baseline_by_name)
      # 检查本地是否存在，不存在就去下载
      check_sdk_old(install_modules)
      # 最后返回所有安装的模块
      install_modules
    end

    # 读取 Component.json 信息
    #
    # @param version 基线版本
    # @return [Hash] 信息内容
    #
    def load_component_info_old(version)
      local_baseline_dir = baseline_dir + version
      download_uri = baseline_component_uri(version)
      # 最新基线版本必须下载，其它版本本地不存在才下载
      if version == @version || !local_baseline_dir.exist?
        DownloadKit.download_file(download_uri, local_baseline_dir, true) do |success|
          raise "下载基线 #{version} 配置失败，请检查网络" unless success
        end
      end
      JSON.parse(File.read(local_baseline_dir + 'Component.json'))
    end

    # 检查本地的模块 SDK 是否存在，不存在就去下载
    #
    # @param [Array<ModuleObject>] modules 检查的模块
    #
    def check_sdk_old(modules)
      modules.each do |m|
        next if m.installed?

        UILogger.info("下载 SDK 到本地: #{m.name}, #{m.version}")
        DownloadKit.download_file(sdk_uri(m.name, m.version), m.local_repo, true) do |success|
          raise "下载 SDK 失败，请检查网络: #{m.name} #{m.version}" unless success
        end
      end
    end

    # 获取模块信息
    # 选择的模块及依赖该模块的模块
    #
    # @param [Array] baseline_by_name 请求的模块名和基线信息
    #                e.g. [[name1, baseline1], [name2, baseline2], ...]
    # @return [Array<ModuleObject>] 模块对象数组
    #
    def fetch_module_info_ref_old(baseline_by_name)
      # 相关模块 + 独立依赖非 component 模块
      related_modules = baseline_by_name.map do |name, baseline|
        fetch_module_obj(name, baseline)
      end.flat_map(&:find_all_refers).uniq
      related_modules
      # related_modules + related_modules.map do |mod|
      #   # 在依赖中找出非component模块，并且引用只有当前删除的模块
      #   mod.dependencies.select { |d| d.refers.reject { |r| r.name == mod.name }.empty? && !d.component? }
      # end.flatten
    end

    # 加载基线配置对应的模块，并缓存
    #
    # @param baseline_version 基线版本号
    # @return [ModuleObject] 模块对象
    #
    def load_modules_old(baseline_version)
      # 有加载的基线内容直接返回
      return @all_modules[baseline_version] if @all_modules.key?(baseline_version)
      UILogger.debug "解析所有配置的模块信息: #{baseline_version}"
      # 下载基线模块信息文件并读取
      component_info = load_component_info_old(baseline_version)
      # 生成模块
      modules = module_info(component_info).map(&ModuleObjectOld.method(:new))
      # 记录所有模块为当前基线
      modules.each { |mod| mod.baseline = baseline_version }
      # 设置依赖模块
      modules.each do |mod|
        mod.dependencies = dependency_info(component_info, mod.name).map do |name, _|
          dep_module = modules.find { |m| m.name == name }
          dep_module.add_refer(mod)
          dep_module
        end
      end
      # 保存所有模块
      @all_modules[baseline_version] = modules
      modules
    end

    # 选择安装的模块
    #
    # @param [Array] baseline_by_name 请求的模块名和基线信息
    #                e.g. [[name1, baseline1], [name2, baseline2], ...]
    # @return [Array<ModuleObject>] 模块对象列表
    #
    def select_install_modules_old(baseline_by_name)
      # 添加所有的模块
      install_modules = baseline_by_name.map { |name, baseline| fetch_module_obj(name, baseline) }
      # 递归添加所有依赖的模块
      install_modules.each do |m|
        install_modules += m.find_dependency_module(install_modules)
      end
      install_modules
    end

    # 读取基线版本下本地 SDK 版本信息
    #
    # @param [String] baseline
    # @return [Array]
    #
    def read_sdk_info_old(baseline)
      component_info = load_component_info_old(baseline)
      Dir.foreach(LocalPath.sdk_home_dir).map do |entry|
        next unless entry =~ /^[A-Z].+/
        # 查找本地
        path = LocalPath.sdk_home_dir + entry
        next unless File.directory?(path)
        # 所有安装的版本
        versions = Dir.foreach(path).select { |sub| sub =~ /^\d+\.\d+\.\d+$/ }.compact
        info = component_info['modules'].find { |m| m['name'] == entry }.map { |k, v| [k.to_sym, v] }.to_h
        # 只返回 component 的模块
        { :name => entry, :versions => versions, :path => path }.merge(info) if info[:group] == 'component'
      end.compact
    end

    # 远程 SDK 信息
    #
    # @param [String] baseline
    # @return [Hash]
    #
    def remote_sdk_info_old(baseline)
      component_info = load_component_info_old(baseline)
      component_info['modules'].map { |info| info.map { |k, v| [k.to_sym, v] }.to_h }
    end

    # 获取基线组件信息的地址
    #
    # @return [String]
    #
    def baseline_component_uri(version)
      MpaasEnv.component_base_uri + '/' + version + '/' + "baseline-#{version}.tgz"
    end

    # sdk 的下载地址
    #
    # @param name 名称
    # @param version 版本号
    #
    def sdk_uri(name, version)
      MpaasEnv.sdk_base_uri + '/' + name + '/' + version.tr('.', '_') + '.tar.gz'
    end

    # 模块的依赖信息（从 component.json 读取）
    #
    def dependency_info(component_info, name)
      component_info['modules'].find { |m| m['name'] == name }.fetch('dependencies', [])
    end

    # 模块信息（从 component.json 读取）
    #
    def module_info(component_info)
      component_info['modules'].map { |h| Hash[h.collect { |k, v| [k.to_sym, v] }] }
    end
  end
end
