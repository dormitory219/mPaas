# frozen_string_literal: true

# mpaas-common.rb
# MpaasKit
#
# Created by quinn on 2019-01-08.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  require 'pathname'
  require 'openssl'
  require 'base64'
  require 'fileutils'
  require 'xcodeproj'
  require 'json'
  require 'open-uri'
  require 'mpaas-common/version'

  require 'mpaas-env'

  autoload :UILogger,             'mpaas-common/ui_logger'
  autoload :SGImageGenerator,     'mpaas-common/sg_image_generator'
  autoload :FileProcessor,        'mpaas-common/file_processor'
  autoload :CommandExecutor,      'mpaas-common/command_executor'
  autoload :DownloadKit,          'mpaas-common/download_kit'
  autoload :XcodeHelper,          'mpaas-common/xcode_helper'
  autoload :PlistAccessor,        'mpaas-common/plist_accessor'
  autoload :BasicInfo,            'mpaas-common/basic_info'
  autoload :Constants,            'mpaas-common/constants'
  autoload :VersionCompare,       'mpaas-common/version_compare'
  autoload :InteractionAssistant, 'mpaas-common/interaction_assistant'
  autoload :Authenticator,        'mpaas-common/authenticator'
  autoload :AppInfoHelper,        'mpaas-common/app_info_helper'
  autoload :DiagnoseReporter,     'mpaas-common/diagnose_reporter'
  autoload :BuildSettingsReader,  'mpaas-common/build_settings_reader'
end