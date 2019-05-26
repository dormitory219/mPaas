# -*- encoding: utf-8 -*-
# stub: mpaas-template 1.1.12 ruby lib

Gem::Specification.new do |s|
  s.name = "mpaas-template".freeze
  s.version = "1.1.12"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["shifei.wkp".freeze]
  s.date = "2019-04-03"
  s.description = "\u{5bf9} mpaas \u{6240}\u{6709}\u{6a21}\u{7248}\u{6587}\u{4ef6}\u{8fdb}\u{884c}\u{7ba1}\u{7406}\u{ff0c}\u{5305}\u{62ec}\u{5de5}\u{7a0b}\u{6a21}\u{7248}\u{ff0c}launcher \u{6a21}\u{7248}\u{ff0c}\u{5934}\u{6587}\u{4ef6}\u{6a21}\u{7248}\u{ff0c}pch \u{6587}\u{4ef6}\u{6a21}\u{7248}\u{ff0c}\u{5206}\u{7c7b}\u{6587}\u{4ef6}\u{6a21}\u{7248}".freeze
  s.email = ["shifei.wkp@antfin.com".freeze]
  s.homepage = "https://tech.antfin.com/products/MPAAS".freeze
  s.required_ruby_version = Gem::Requirement.new(">= 2.3".freeze)
  s.rubygems_version = "2.7.9".freeze
  s.summary = "mpaas \u{6a21}\u{7248}\u{7ba1}\u{7406}\u{6a21}\u{5757}".freeze

  s.installed_by_version = "2.7.9" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<mpaas-common>.freeze, [">= 1.1.18"])
      s.add_runtime_dependency(%q<mpaas-env>.freeze, [">= 1.1.10"])
      s.add_development_dependency(%q<bundler>.freeze, ["~> 2.0"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.2"])
    else
      s.add_dependency(%q<mpaas-common>.freeze, [">= 1.1.18"])
      s.add_dependency(%q<mpaas-env>.freeze, [">= 1.1.10"])
      s.add_dependency(%q<bundler>.freeze, ["~> 2.0"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3.2"])
    end
  else
    s.add_dependency(%q<mpaas-common>.freeze, [">= 1.1.18"])
    s.add_dependency(%q<mpaas-env>.freeze, [">= 1.1.10"])
    s.add_dependency(%q<bundler>.freeze, ["~> 2.0"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.2"])
  end
end
