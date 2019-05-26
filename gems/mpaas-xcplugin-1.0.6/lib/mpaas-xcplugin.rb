# frozen_string_literal: true

# mpaas-xcplugin.rb
# MpaasKit
#
# Created by quinn on 2019-01-16.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  require 'fileutils'
  require 'pathname'
  require 'tmpdir'
  require 'mpaas-xcplugin/version'

  require 'mpaas-common'
  require 'mpaas-env'

  require 'mpaas-xcplugin/xcplugin'
  require 'mpaas-xcplugin/plugin_manager'
end