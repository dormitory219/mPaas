# -*- encoding: utf-8 -*-
# stub: mpaas-xcplugin 1.0.6 ruby lib

Gem::Specification.new do |s|
  s.name = "mpaas-xcplugin".freeze
  s.version = "1.0.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["shifei.wkp".freeze]
  s.date = "2019-04-03"
  s.description = "\u{5305}\u{62ec} xcode \u{63d2}\u{4ef6}\u{5b89}\u{88c5}\u{ff0c}\u{5220}\u{9664}\u{ff0c}\u{66f4}\u{65b0}\u{ff0c}\u{4e0b}\u{8f7d}".freeze
  s.email = ["shifei.wkp@antfin.com".freeze]
  s.homepage = "https://tech.antfin.com/products/MPAAS".freeze
  s.required_ruby_version = Gem::Requirement.new(">= 2.3".freeze)
  s.rubygems_version = "2.7.9".freeze
  s.summary = "mpaas \u{4e2d} xcode \u{63d2}\u{4ef6}\u{6a21}\u{5757}".freeze

  s.installed_by_version = "2.7.9" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<mpaas-common>.freeze, [">= 1.1.18"])
      s.add_runtime_dependency(%q<mpaas-env>.freeze, [">= 1.1.10"])
      s.add_runtime_dependency(%q<reuse_xcode_plugins>.freeze, [">= 0"])
      s.add_development_dependency(%q<bundler>.freeze, ["~> 2.0"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.2"])
    else
      s.add_dependency(%q<mpaas-common>.freeze, [">= 1.1.18"])
      s.add_dependency(%q<mpaas-env>.freeze, [">= 1.1.10"])
      s.add_dependency(%q<reuse_xcode_plugins>.freeze, [">= 0"])
      s.add_dependency(%q<bundler>.freeze, ["~> 2.0"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3.2"])
    end
  else
    s.add_dependency(%q<mpaas-common>.freeze, [">= 1.1.18"])
    s.add_dependency(%q<mpaas-env>.freeze, [">= 1.1.10"])
    s.add_dependency(%q<reuse_xcode_plugins>.freeze, [">= 0"])
    s.add_dependency(%q<bundler>.freeze, ["~> 2.0"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.2"])
  end
end
