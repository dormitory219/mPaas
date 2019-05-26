# frozen_string_literal: true

# mpaas_framework_system.rb
# MpaasKit
#
# Created by quinn on 2019-03-11.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # mpaas 框架，处理系统依赖部分
  #
  class MpaasFramework
    private

    def remove_system_dependencies(target_info, target_name)
      UILogger.info('移除系统库依赖')
      frameworks = target_info.sys_frameworks.map { |name, _| name }
      XcodeHelper.remove_system_frameworks(@project.xcodeproj_path, target_name, frameworks)
      # TODO: 系统 lib
    end

    # 处理系统库依赖
    #
    # @param [MpaasTargetInfo] target_info
    # @param [String] target_name
    #
    def handle_system_dependencies(target_info, target_name)
      UILogger.info('处理系统库依赖')
      handle_system_frameworks(target_name, target_info)
      target_info.sys_libraries.each do |_, op|
        # TODO: 系统 lib
        if op == :add
        elsif op == :del
        end
      end
    end

    # 处理 framework
    #
    # @param [MpaasTargetInfo] target_info
    # @param [String] target_name
    #
    def handle_system_frameworks(target_name, target_info)
      del_frameworks = []
      add_frameworks = []
      target_info.sys_frameworks.each do |name, op|
        if op == :del
          del_frameworks << name
        elsif op == :add
          add_frameworks << name
        end
      end
      XcodeHelper.remove_system_frameworks(@project.xcodeproj_path, target_name, del_frameworks)
      XcodeHelper.add_system_frameworks(@project.xcodeproj_path, target_name, add_frameworks)
    end
  end
end
