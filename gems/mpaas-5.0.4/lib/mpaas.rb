# frozen_string_literal: true

# mpaas.rb
# MpaasKit
#
# Created by quinn on 2019-01-14.
# Copyright © 2019 alipay. All rights reserved.
#

require 'rubygems'

# mpaas
#
module Mpaas
  require 'optparse'
  require 'pathname'
  require 'fileutils'

  require 'mpaas/version'
  require 'mpaas-core'
  require 'mpaas-xcplugin'
  require 'mpaas/config'

  autoload :Command,  'mpaas/command'
  autoload :Parser,   'mpaas/parser'
  autoload :Entry,    'mpaas/entry'
end
