# frozen_string_literal: true

# constants.rb
# MpaasKit
#
# Created by quinn on 2019-02-01.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class Constants
    # mpaas 框架组对应的 key
    MPAAS_GROUP_KEY = 'MPaaS'             # mpaas 框架组名称
    TARGETS_GROUP_KEY = 'Targets'         # mpaas targets 组名称
    FRAMEWORKS_GROUP_KEY = 'Frameworks'   # mpaas frameworks 组名称
    RESOURCES_GROUP_KEY = 'Resources'     # mpaas resources 组名称

    # 常量字符串
    INHERITED = '$(inherited)' # build setting 中的 inherited

    # 文件名常量
    APP_INFO_FILE_NAME = 'meta.config'    # 云端数据文件名
    SG_IMAGE_FILE_NAME = 'yw_1222.jpg'    # 无线保镖图片文件名

    # 云端配置中对应的 key
    CONFIG_RPC_GW_KEY = 'rpcGW'             # mgs 地址
    CONFIG_APP_KEY_KEY = 'appKey'           # 应用 app key
    CONFIG_APP_ID_KEY = 'appId'             # 应用 app id
    CONFIG_LOG_GW_KEY = 'logGW'             # mas 地址
    CONFIG_MPAAS_API_KEY = 'mpaasapi'       # 组件网关地址
    CONFIG_WORKSPACE_ID_KEY = 'workspaceId' # 应用 workspace id
    CONFIG_SYNC_SERVER_KEY = 'syncserver'   # mss 地址
    CONFIG_SYNC_PORT_KEY = 'syncport'       # mss 端口
    CONFIG_BUNDLE_ID_KEY = 'bundleId'       # 应用 bundle id
    CONFIG_BASE64_CODE_KEY = 'base64Code'   # 无线保镖图片 base64 码

    # mpaas info
    MPAAS_FILE_NAME = 'mpaas_sdk.config'    # mpaas info 文件名
    MPAAS_FILE_NOTICE_KEY = 'notice'        # mpaas info notice
    MPAAS_FILE_PROJECT_KEY = 'project'      # mpaas info project
    MPAAS_FILE_COPY_KEY = 'copy'            # mpaas info copy
    MPAAS_FILE_RECENT_KEY = 'recent'        # mpaas info recent
    MPAAS_FILE_TARGETS_KEY = 'targets'      # mpaas info targets
    MPAAS_FILE_AUTHOR_KEY = 'author'        # mpaas info author
    MPAAS_FILE_TIME_KEY = 'time'            # mpaas info time
    MPAAS_FILE_VERSIONS_KEY = 'versions'    # mpaas info versions
    MPAAS_FILE_BASELINE_KEY = 'baseline'    # mpaas info baseline
    MPAAS_FILE_FRAMEWORK_KEY = 'frameworks' # mpaas info frameworks
    MPAAS_FILE_RESOURCE_KEY = 'resources'   # mpaas info resources

    # Info.plist key
    INFO_PLIST_PRODUCT_ID_KEY = 'Product ID'            # plist 中的 product id
    INFO_PLIST_PRODUCT_VERSION_KEY = 'Product Version'  # plist 中的 product version
    INFO_PLIST_MPAAS_KEY = 'mPaaS'                      # plist 中的 mpaas
    INFO_PLIST_MPAAS_INTERNAL_KEY = 'mPaaSInternal'     # plist 中的 mpaas internal
  end
end
