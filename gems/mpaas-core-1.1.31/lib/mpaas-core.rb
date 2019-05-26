# frozen_string_literal: true

# mpaas-core.rb
# MpaasKit
#
# Created by quinn on 2019-01-10.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  require 'pathname'
  require 'json'
  require 'fileutils'
  require 'mpaas-core/version'

  require 'mpaas-project'

  autoload :ModuleManager,    'mpaas-core/module_manager'
  autoload :BaselineManager,  'mpaas-core/baseline_manager'
  autoload :Resolver,         'mpaas-core/resolver'
  autoload :FrameworkObject,  'mpaas-core/module_object/framework_object'
  autoload :ModuleConfig,     'mpaas-core/module_object/module_config'
  autoload :ModuleObject,     'mpaas-core/module_object'
  autoload :ModuleObjectOld,  'mpaas-core/module_object/module_object_old'
  autoload :MpaasTargetInfo,  'mpaas-core/mpaas_target_info'
  autoload :MpaasInfo,        'mpaas-core/mpaas_info'
  autoload :MpaasFramework,   'mpaas-core/mpaas_framework'
  autoload :BackupKit,        'mpaas-core/backup'
  autoload :UpdateInfo,       'mpaas-core/update_info'
  autoload :UserContentImage, 'mpaas-core/user_content_image'
  autoload :ImageNode,        'mpaas-core/user_content_image/image_node'
end