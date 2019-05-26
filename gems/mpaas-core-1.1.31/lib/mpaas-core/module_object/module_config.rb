# frozen_string_literal: true

# module_config.rb
# MpaasKit
#
# Created by quinn on 2019-03-10.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 模块配置信息
  #
  class ModuleConfig
    # 系统库名称
    #
    module SystemFrameworkName
      SYS_FW_CM = 'CoreMotion.framework'
      SYS_FW_CT = 'CoreTelephony.framework'
      SYS_FW_SC = 'SystemConfiguration.framework'
      SYS_FW_UN = 'UserNotifications.framework'
      SYS_FW_AS = 'AssetsLibrary.framework'
      SYS_FW_AV = 'AVFoundation.framework'
      SYS_FW_MU = 'MessageUI.framework'
      SYS_FW_PH = 'Photos.framework'
      SYS_FW_AC = 'Accelerate.framework'
      SYS_FW_WK = 'WebKit.framework'
      SYS_FW_VI = 'ImageIO.framework'
      SYS_FW_AT = 'AudioToolbox.framework'
      SYS_FW_VT = 'VideoToolbox.framework'
      SYS_FW_MS = 'MobileCoreServices.framework'
      SYS_FW_JS = 'JavaScriptCore.framework'
      SYS_FW_MK = 'MapKit.framework'
      SYS_FW_CL = 'CoreLocation.framework'
    end

    # noinspection RubyStringKeysInHashInspection
    class << self
      include SystemFrameworkName

      # 系统依赖 framework 对应关系
      # TODO: 后续在每个模块的配置文件中进行配置
      #
      # @return [Hash]
      #
      def framework_for_name(name)
        framework_hash = {
          'SecurityGuardSDK' => [SYS_FW_CT],                    'APLog' => [SYS_FW_SC],
          'APMobileFramework' => [SYS_FW_UN],                   'APMobileNetwork' => [SYS_FW_CM, SYS_FW_CT],
          'MPSyncService' => [SYS_FW_CM, SYS_FW_MU, SYS_FW_CT], 'MPHotpatchSDK' => [SYS_FW_CM, SYS_FW_MU, SYS_FW_CT],
          'MPScanCode' => [SYS_FW_VI, SYS_FW_AS, SYS_FW_AV],    'APMobileLBS' => [SYS_FW_CM],
          'MPCommonUI' => [SYS_FW_AC, SYS_FW_SC],               'MPShareKit' => [SYS_FW_CT],
          'AlipaySDK' => [SYS_FW_CT],                           'APRemoteLogging' => [SYS_FW_CT, SYS_FW_WK],
          'Nebula' => [SYS_FW_UN, SYS_FW_CM, SYS_FW_AC, SYS_FW_MU, SYS_FW_SC],
          'TinyApp' => [SYS_FW_CM, SYS_FW_AT, SYS_FW_VT, SYS_FW_MS, SYS_FW_PH, SYS_FW_MK, SYS_FW_JS,
                        'EventKit.framework', 'AddressBookUI.framework', 'NetworkExtension.framework',
                        'MediaPlayer.framework', 'ContactsUI.framework', 'Contacts.framework', 'AddressBook.framework'],
          'MPMultimedia' => [SYS_FW_CM, SYS_FW_AT, SYS_FW_MS, SYS_FW_PH, SYS_FW_MK, SYS_FW_AV, SYS_FW_AS, SYS_FW_CL,
                             SYS_FW_MU, 'MediaPlayer.framework', 'CoreMedia.framework']
        }
        framework_hash.map { |k, v| [module_name(k), v] }.to_h.fetch(module_name(name), [])
      end

      # 头文件黑名单
      # v4 使用
      #
      # @return [Array]
      #
      def public_header_black_list
        %w[SecurityGuardSDK UTDID TianYan MPSyncService APProtocolBuffers APOpenSSL APSecurityUtility
           MPPerformance MPDiagnosis AntLog mPaas MPPipeLine NebulaSDKPlugins]
      end

      # 系统依赖的 lib
      #
      # @return [Hash]
      #
      def library_for_name(name)
        { 'MPScanCode' => %w[libz.tbd] }.fetch(module_name(name), [])
      end

      # 冲突的工程包
      #
      # @return [Array<FrameworkObject>] 需要去掉的冲突库名称
      #
      def conflict_frameworks
        return [] unless block_given?
        conflict_set = %w[MPNebulaSDKPlugins NebulaSDKPlugins]
        # 从冲突集合里面筛选
        candidates = conflict_set.map { |n| yield n }.compact
        # 只有都存在才有冲突
        return [] if candidates.count != conflict_set.count
        # 找出删除的模块
        del_candidates = candidates.select { |_, op| op == :del }
        if del_candidates.empty?
          # 全部添加，把集合中第一个移除
          [candidates.first.first]
        elsif del_candidates.count == 1
          # 冲突之一删除，直接移除
          [del_candidates.first.first]
        else
          # 全部移除
          del_candidates.map(&:first)
        end
      end

      # 分类文件的白名单，以 framework 名为准
      # v5 使用
      #
      # @return [Array]
      #
      def category_white_list
        %w[APMobileFramework mPaas]
      end

      # 强制恢复的分类目录
      #
      # @return [Array]
      #
      def force_recovery_category
        category_white_list
      end

      # 本地日志
      MODULE_LOG = %w[APLog mPaaS_LocalLog].freeze
      # 移动分析
      MODULE_REMOTE_LOGGING = %w[APRemoteLogging mPaaS_Log].freeze
      MODULE_AUTO_TRACKER = %w[AutoTracker mPaaS_Log].freeze
      MODULE_CRASH_REPORTER = %w[APCrashReporter mPaaS_Log].freeze
      MODULE_PERFORMANCE = %w[MPPerformance mPaaS_Log].freeze
      # 诊断
      MODULE_DIAGNOSIS = %w[MPDiagnosis mPaaS_Diagnosis].freeze
      # 移动网络
      MODULE_RPC = %w[APMobileNetwork mPaaS_RPC].freeze
      # 移动同步
      MODULE_SYNC = %w[MPSyncService mPaaS_Sync].freeze
      MODULE_SYNC_TEST = %w[APLongLinkService mPaaS_Sync].freeze
      # 推送
      MODULE_PUSH = %w[MPPushSDK mPaaS_Push].freeze
      # 开关配置
      MODULE_CONFIG = %w[APConfig mPaaS_Config].freeze
      # 热修复
      MODULE_HOTPATCH = %w[MPHotpatchSDK mPaaS_Hotpatch].freeze
      # 升级
      MODULE_UPGRADE = %w[MPUpgradeCheckService mPaaS_Upgrade].freeze
      MODULE_UPGRADE_TEST = %w[AliUpgradeCheckService mPaaS_Upgrade].freeze
      # 分享
      MODULE_SHARE = %w[MPShareKit mPaaS_Share].freeze
      # H5容器和离线包
      MODULE_NEBULA = %w[Nebula mPaaS_Nebula].freeze
      MODULE_NEBULA_PACKAGE = %w[NebulamPaaSBiz mPaaS_Nebula].freeze
      MODULE_JS_API = %w[NebulaSDKPlugins mPaaS_Nebula].freeze
      MODULE_NEBULA_LOGGING = %w[NebulaLogging mPaaS_Nebula].freeze
      # 设备标识
      MODULE_UTDID = %w[UTDID mPaaS_UTDID].freeze
      # 统一存储
      MODULE_DATA_CENTER = %w[MPDataCenter mPaaS_DataCenter].freeze
      # 扫一扫
      MODULE_SCAN_CODE = %w[MPScanCode mPaaS_ScanCode].freeze
      MODULE_SCAN_CODE_TEST = %w[TBScanSDK mPaaS_ScanCode].freeze
      # 定位
      MODULE_LBS = %w[APMobileLBS mPaaS_LBS].freeze
      # 通用UI
      MODULE_COMMON_UI = %w[MPCommonUI mPaaS_CommonUI].freeze
      MODULE_COMMON_UI_TEST = %w[APCommonUI mPaaS_CommonUI].freeze
      # 红点
      MODULE_BADGE = %w[MPBadgeService mPaaS_BadgeService].freeze
      # 支付SDK
      MODULE_ALIPAY = %w[AlipaySDK mPaaS_AlipaySDK].freeze
      # 多媒体
      MODULE_MULTIMEDIA = %w[MPMultimedia mPaaS_Multimedia].freeze
      MODULE_MULTIMEDIA_TEST = %w[APMultimedia mPaaS_Multimedia].freeze
      # 移动框架
      MODULE_MOBILE_FRAMEWORK = %w[APMobileFramework mPaaS_MobileFramework].freeze
      # openssl
      MODULE_OPENSSL = %w[APOpenSSL mPaaS_OpenSSL].freeze
      # 小程序
      MODULE_TINY_APP = %w[TinyApp mPaaS_TinyApp].freeze
      # 拼音搜索
      MODULE_PINYIN_SEARCH = %w[MPPinyinSearch mPaaS_PinyinSearch].freeze

      # 模块名映射
      #
      # @param [String] name
      # @return [String, nil]
      #
      def module_name(name)
        name_hash = [
          # 测试环境
          MODULE_SYNC_TEST, MODULE_UPGRADE_TEST, MODULE_SCAN_CODE_TEST, MODULE_COMMON_UI_TEST, MODULE_MULTIMEDIA_TEST,
          # 正式环境
          MODULE_LOG, MODULE_REMOTE_LOGGING, MODULE_AUTO_TRACKER, MODULE_CRASH_REPORTER, MODULE_PERFORMANCE,
          MODULE_DIAGNOSIS, MODULE_RPC, MODULE_SYNC, MODULE_PUSH, MODULE_CONFIG, MODULE_HOTPATCH,
          MODULE_UPGRADE, MODULE_SHARE, MODULE_NEBULA, MODULE_NEBULA_PACKAGE, MODULE_JS_API,
          MODULE_NEBULA_LOGGING, MODULE_UTDID, MODULE_DATA_CENTER, MODULE_SCAN_CODE, MODULE_LBS,
          MODULE_COMMON_UI, MODULE_BADGE, MODULE_ALIPAY, MODULE_MULTIMEDIA, MODULE_MOBILE_FRAMEWORK,
          MODULE_OPENSSL, MODULE_TINY_APP, MODULE_PINYIN_SEARCH
        ].to_h
        BasicInfo.instance.active_v4 ? name.to_s : name_hash.fetch(name.to_s, name.to_s)
      end
    end
  end
end
