# frozen_string_literal: true

# mpaas-template.rb
# MpaasKit
#
# Created by quinn on 2019-01-09.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  require 'pathname'
  require 'tmpdir'
  require 'mpaas-template/version'

  require 'mpaas-common'

  autoload :BaseTemplate,         'mpaas-template/template/template'
  autoload :ProjectTemplate,      'mpaas-template/template/project_template'
  autoload :AppTemplate,          'mpaas-template/template/app_template'
  autoload :CategoryTemplate,     'mpaas-template/template/category_template'
  autoload :HeaderTemplate,       'mpaas-template/template/header_template'
  autoload :PchTemplate,          'mpaas-template/template/pch_template'
  autoload :TemplatesFactory,     'mpaas-template/template_factory'
  autoload :EntitlementTemplate,  'mpaas-template/template/entitlement_template'
end