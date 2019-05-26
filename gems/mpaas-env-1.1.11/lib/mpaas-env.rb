# frozen_string_literal: true

# mpaas-env.rb
# MpaasKit
#
# Created by quinn on 2019-01-07.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  require 'pathname'
  require 'tmpdir'
  require 'mpaas-env/version'

  autoload :MpaasEnv,   'mpaas-env/environment'
  autoload :LocalPath,  'mpaas-env/local_path'
  autoload :SystemInfo, 'mpaas-env/system_info'
end