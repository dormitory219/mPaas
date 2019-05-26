# frozen_string_literal: true

# module_manager_required.rb
# MpaasKit
#
# Created by quinn on 2019-03-11.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 模块管理，必要的模块解析
  #
  class ModuleManager
    private

    # 必须添加的模块
    #
    # @return [Array]
    #
    def required_modules
      @required_modules ||= if @project.using_mobile_framework?(@project.active_target)
                              [ModuleConfig.module_name('APMobileFramework')]
                            else
                              []
                            end
    end
  end
end
