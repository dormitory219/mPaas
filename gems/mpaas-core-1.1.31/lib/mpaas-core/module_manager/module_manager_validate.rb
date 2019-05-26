# frozen_string_literal: true

# module_manager_validate.rb
# MpaasKit
#
# Created by quinn on 2019-03-10.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 模块管理，校验参数等
  #
  class ModuleManager
    private

    # 该target是否包含mpaas模块
    #
    # @param [String] target
    # @return [Bool]
    #
    def target_include_mpaas?(target)
      !@resolver.resolve_module_versions_info(target).nil?
    end

    # 校验基线版本是否一致
    #
    def validate_update_baseline
      baseline_version = @resolver.resolved_current_baseline
      return if basic_info.active_v4 || @baseline_manager.version == baseline_version
      # 基线版本不一致
      UILogger.error('基线版本不一致，请升级基线')
      exit(13)
    end

    # 校验 target 是否集成 mpaas
    #
    def validate_active_target
      return if target_include_mpaas?(@project.active_target)
      # 无 mpaas
      UILogger.error('当前 Target 没有集成 mPaaS，无法执行该操作')
      exit(14)
    end
  end
end
