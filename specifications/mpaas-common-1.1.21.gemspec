# -*- encoding: utf-8 -*-
# stub: mpaas-common 1.1.21 ruby lib

Gem::Specification.new do |s|
  s.name = "mpaas-common".freeze
  s.version = "1.1.21"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["shifei.wkp".freeze]
  s.date = "2019-05-06"
  s.description = "\u{63d0}\u{4f9b}\u{57fa}\u{7840}\u{5de5}\u{5177}\u{ff0c}\u{5305}\u{62ec}\u{65e5}\u{5fd7}\u{5de5}\u{5177}\u{ff0c}xcode\u{5de5}\u{5177}\u{ff0c}\u{65e0}\u{7ebf}\u{4fdd}\u{9556}\u{56fe}\u{7247}\u{5de5}\u{5177}\u{ff0c}\u{4e0b}\u{8f7d}\u{5de5}\u{5177}\u{ff0c}\u{547d}\u{4ee4}\u{884c}\u{5de5}\u{5177}\u{ff0c}plist \u{5de5}\u{5177}\u{ff0c}\u{6587}\u{4ef6}\u{5904}\u{7406}\u{5de5}\u{5177}".freeze
  s.email = ["shifei.wkp@antfin.com".freeze]
  s.homepage = "https://tech.antfin.com/products/MPAAS".freeze
  s.required_ruby_version = Gem::Requirement.new(">= 2.3".freeze)
  s.rubygems_version = "2.7.9".freeze
  s.summary = "mpaas \u{516c}\u{5171}\u{57fa}\u{7840}\u{5305}".freeze

  s.installed_by_version = "2.7.9" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<mpaas-env>.freeze, [">= 1.1.10"])
      s.add_runtime_dependency(%q<xcodeproj>.freeze, [">= 1.7.0", "< 2.0"])
      s.add_development_dependency(%q<bundler>.freeze, ["~> 2.0"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.2"])
    else
      s.add_dependency(%q<mpaas-env>.freeze, [">= 1.1.10"])
      s.add_dependency(%q<xcodeproj>.freeze, [">= 1.7.0", "< 2.0"])
      s.add_dependency(%q<bundler>.freeze, ["~> 2.0"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3.2"])
    end
  else
    s.add_dependency(%q<mpaas-env>.freeze, [">= 1.1.10"])
    s.add_dependency(%q<xcodeproj>.freeze, [">= 1.7.0", "< 2.0"])
    s.add_dependency(%q<bundler>.freeze, ["~> 2.0"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.2"])
  end
end
