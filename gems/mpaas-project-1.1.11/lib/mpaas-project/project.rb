# frozen_string_literal: true

# project.rb
# MpaasKit
#
# Created by quinn on 2019-01-09.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # xcode 工程对象
  #
  class XCProjectObject
    # 工程类型
    #
    module ProjectType
      # 系统标准工程（单工程）
      SYSTEM_STANDARD = 0
      # 系统 pod 工程
      SYSTEM_POD = 1
      # mpaas框架标准工程（单工程）
      MPAAS_STANDARD = 2
      # mpaas框架 pod 工程
      MPAAS_POD = 3
    end
    include ProjectType

    # 初始化
    #
    # @param name 工程名称, xcodeproj 文件名
    # @param type [Symbol] 工程类型，如果传 nil 表示自己解析类型
    # @param src_root 工程的 src root 路径
    # @param active_target 当前处理的 target 名称
    #
    def initialize(name, type, src_root, active_target)
      @name = name
      @type = type
      @src_root = Pathname.new(src_root).realdirpath
      @active_target = active_target
      @mpaas_file = MpaasFile.open(src_root)
      @using_mobile_framework = {}
    end

    attr_reader :name,          # 工程名称
                :src_root,      # 工程主目录
                :active_target, # 当前操作的 target 名称
                :mpaas_file,    # 当前工程的 mpaas file
                :mpaas_targets  # 集成 mpaas 的 targets

    # 工程类型
    #
    # @return [ProjectType]
    #
    def project_type
      @project_type ||= parse_project_type
    end

    # 是否为 mpaas 工程
    # mpaas 配置文件是否存在
    #
    # @return [Bool]
    #
    def mpaas_project?
      project_type == MPAAS_STANDARD || project_type == MPAAS_POD
    end

    # 工程中所有 target 名称
    #
    # @return [Array<String>]
    #
    def targets
      @targets ||= XcodeHelper.all_targets_name(xcodeproj_path)
    end

    # 解析 mpaas target
    # TODO: 后续新建target对象
    #
    # @param [Array] targets
    #
    def parse_mpaas_targets=(targets)
      # 需要添加当前编辑的 target，首次集成标记
      @mpaas_targets = (targets + [@active_target]).uniq
      # 解析是否使用框架
      parse_using_mobile_framework
    end

    # 某target是否使用mpaas移动框架
    #
    # @param [String] target
    # @return [Bool]
    #
    def using_mobile_framework?(target)
      @using_mobile_framework.fetch(target, false)
    end

    # .xcodeproj 工程文件路径
    #
    # @return [Pathname]
    #
    def xcodeproj_path
      @xcodeproj_path ||= Pathname.new(@src_root) + "#{@name}.xcodeproj"
    end

    # 云端配置信息文件路径
    #
    # @param [String] target_name
    # @return [Pathname] 路径
    #
    def app_info_file_path(target_name)
      @src_root + Constants::MPAAS_GROUP_KEY + Constants::TARGETS_GROUP_KEY +
        target_name + Constants::APP_INFO_FILE_NAME
    end

    private

    # 解析各target 是否使用 mpaas 移动框架
    #
    def parse_using_mobile_framework
      @mpaas_targets.each do |target|
        # 获取工程 target 是否可执行应用
        next unless XcodeHelper.target_executable?(@xcodeproj_path, target)
        # 取 main.m 文件路径
        main_path = XcodeHelper.search_from_build_phase(@xcodeproj_path, target,
                                                        XcodeHelper::BuildPhaseName::SOURCES, 'main.m')
        next if main_path.nil?
        # 去除注释掉的行，存在框架的代码标记
        @using_mobile_framework[target] = !File.readlines(main_path)
                                               .select { |l| l.include?('// NOW USE MPAAS FRAMEWORK') }
                                               .reject { |line| line =~ %r{^\s*//[.\s]*return} }
                                               .empty?
      end
    end

    # 工程类型（默认 mpaas 单工程）
    #
    # @return [ProjectType]
    #
    def parse_project_type
      {
        SYSTEM_STANDARD => :sys_type?, SYSTEM_POD => :sys_pod_type?,
        MPAAS_STANDARD => :mpaas_type?, MPAAS_POD => :mpaas_pod_type?
      }.select { |_, sym| method(sym).call }.keys.first
    end

    # 是否为系统标准类型
    #
    # @return [Bool]
    #
    def sys_type?
      @type == :sys || (@type.nil? && !@mpaas_file.exist? && !pod_project?)
    end

    # 是否为系统 pod 类型
    #
    # @return [Bool]
    #
    def sys_pod_type?
      @type == :sys_pod || (@type.nil? && !@mpaas_file.exist? && pod_project?)
    end

    # 是否为 mpaas 标准类型
    #
    # @return [Bool]
    #
    def mpaas_type?
      @type == :mpaas || (@type.nil? && @mpaas_file.exist? && !pod_project?)
    end

    # 是否为 mpaas pod 类型
    #
    # @return [Bool]
    #
    def mpaas_pod_type?
      @type == :mpaas_pod || (@type.nil? && @mpaas_file.exist? && pod_project?)
    end

    # 是否为 pod 工程
    # Podfile.lock 或 Podfile 文件是否存在
    #
    # @return [Bool]
    #
    def pod_project?
      (@src_root + 'Podfile.lock').exist? || (@src_root + 'Podfile').exist?
    end
  end
end
