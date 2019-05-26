# frozen_string_literal: true

# component_const.rb
# MpaasKit
#
# Created by quinn on 2019-03-06.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 常量
  #
  class ComponentConst
    class << self
      # 模块名表
      #
      # @return [Hash]
      #
      def module_name_map
        {
          :APLog => 'mPaaS_LocalLog',                 :APRemoteLogging => 'mPaaS_Log',
          :AutoTracker => 'mPaaS_AutoTracker',        :MPPerformance => 'mPaaS_Performance',
          :APCrashReporter => 'mPaaS_Crash',          :MPDiagnosis => 'mPaaS_Diagnosis',
          :APMobileNetwork => 'mPaaS_MobileNetwork',  :MPSyncService => 'mPaaS_Sync',
          :MPPushSDK => 'mPaaS_Push',                 :APConfig => 'mPaaS_Config',
          :MPHotpatchSDK => 'mPaaS_Hotpatch',         :MPUpgradeCheckService => 'mPaaS_Upgrade',
          :MPShareKit => 'mPaaS_Share',               :Nebula => 'mPaaS_Nebula',
          :NebulaLogging => 'mPaaS_NebulaLogging',    :NebulamPaaSBiz => 'mPaaS_NebulaPackage',
          :NebulaSDKPlugins => 'mPaaS_JsApi',         :TinyApp => 'mPaaS_TinyApp',
          :UTDID => 'mPaaS_UTDID',                    :MPDataCenter => 'mPaaS_DataCenter',
          :MPScanCode => 'mPaaS_ScanCode',            :APMobileLBS => 'mPaaS_MobileLBS',
          :MPCommonUI => 'mPaaS_CommonUI',            :MPBadgeService => 'mPaaS_BadgeService',
          :MPPinyinSearch => 'mPaaS_PinyinSearch',    :AlipaySDK => 'mPaaS_AlipaySDK',
          :MPMultimedia => 'mPaaS_Multimedia',        :APMobileFramework => 'mPaaS_MobileFramework',
          :APOpenSSL => 'mPaaS_OpenSSL'
        }.freeze
      end

      # 系统依赖表
      #
      # @return [Hash]
      #
      def system_dependency_map
        {
          :APMobileFramework => %w[UserNotifications.framework],
          :APMobileNetwork => %w[CoreMotion.framework CoreTelephony.framework],
          :MPSyncService => %w[CoreMotion.framework MessageUI.framework],
          :MPHotpatchSDK => %w[CoreMotion.framework MessageUI.framework],
          :Nebula => %w[UserNotifications.framework CoreMotion.framework Accelerate.framework
                        MessageUI.framework SystemConfiguration.framework],
          :TinyApp => %w[CoreMedia.framework AudioToolbox.framework VideoToolbox.framework MobileCoreServices.framework
                         Photos.framework MapKit.framework JavaScriptCore.framework EventKit.framework],
          :MPMultimedia => %w[CoreMedia.framework AudioToolbox.framework MobileCoreServices.framework
                              Photos.framework MediaPlayer.framework MapKit.framework AVFoundation.framework
                              AssetsLibrary.framework CoreLocation.framework],
          :MPScanCode => %w[ImageIO.framework AssetsLibrary.framework AVFoundation.framework],
          :APMobileLBS => %w[CoreMotion.framework],
          :MPCommonUI => %w[Accelerate.framework SystemConfiguration.framework],
          :MPShareKit => %w[CoreTelephony.framework],
          :APRemoteLogging => %w[CoreTelephony.framework],
          :APLog => %w[SystemConfiguration.framework]
        }.freeze
      end
    end
  end
end
