# frozen_string_literal: true

# plugin_manager.rb
# MpaasKit
#
# Created by quinn on 2019-03-03.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  module XCPlugin
    # Xcode 插件管理
    #
    class PluginManager
      class << self
        # 刷新插件的 uuid
        #
        def refresh_plugins_uuid
          PluginsUpdater.update_plugins
        end

        # 去除 Xcode 签名
        #
        def unsign_xcode
          UILogger.console('Xcode 即将去掉签名，如果你已经去掉了 Xcode 的签名或者不想去掉签名，可以跳过该步骤')
          UILogger.console('[注意!] 如果不去除签名，Xcode 插件将无法正常使用', :yellow)
          answer = InteractionAssistant.ask_with_answers('是否确认去除 Xcode 签名', %w[Y N])
          XcodeUnsigner.unsign_xcode if answer.casecmp('y').zero?
        end

        # 恢复 Xcode 签名
        #
        def restore_xcode
          XcodeUnsigner.restore_xcode
        end
      end
    end
  end
end
