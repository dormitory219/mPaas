# frozen_string_literal: true

# mpaas-project.rb
# MpaasKit
#
# Created by quinn on 2019-01-09.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  require 'pathname'
  require 'fileutils'
  require 'mpaas-project/version'

  require 'mpaas-template'

  autoload :XCProjectObject,  'mpaas-project/project'
  autoload :ProjectGenerator, 'mpaas-project/project_generator'
  autoload :MpaasFile,        'mpaas-project/mpaas_file'
end