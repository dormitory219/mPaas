# -*- encoding: utf-8 -*-
# stub: mpaas-core 1.1.31 ruby lib

Gem::Specification.new do |s|
  s.name = "mpaas-core".freeze
  s.version = "1.1.31"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["shifei.wkp".freeze]
  s.date = "2019-05-06"
  s.description = "\u{8d1f}\u{8d23}\u{5bf9}\u{5df2}\u{6709}\u{5de5}\u{7a0b}/\u{65b0}\u{5efa}\u{5de5}\u{7a0b}\u{ff0c}\u{8fdb}\u{884c}\u{6a21}\u{5757}\u{7684}\u{7f16}\u{8f91}\u{548c}\u{5347}\u{7ea7}\u{ff0c}SDK \u{7ba1}\u{7406}\u{ff0c}\u{57fa}\u{7ebf}\u{7ba1}\u{7406}".freeze
  s.email = ["shifei.wkp@antfin.com".freeze]
  s.homepage = "https://tech.antfin.com/products/MPAAS".freeze
  s.required_ruby_version = Gem::Requirement.new(">= 2.3".freeze)
  s.rubygems_version = "2.7.9".freeze
  s.summary = "mpaas \u{6838}\u{5fc3}\u{6a21}\u{5757}".freeze

  s.installed_by_version = "2.7.9" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<mpaas-common>.freeze, [">= 1.1.18"])
      s.add_runtime_dependency(%q<mpaas-env>.freeze, [">= 1.1.10"])
      s.add_runtime_dependency(%q<mpaas-project>.freeze, [">= 1.1.11"])
      s.add_runtime_dependency(%q<mpaas-template>.freeze, [">= 1.1.12"])
      s.add_development_dependency(%q<bundler>.freeze, ["~> 2.0"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.2"])
    else
      s.add_dependency(%q<mpaas-common>.freeze, [">= 1.1.18"])
      s.add_dependency(%q<mpaas-env>.freeze, [">= 1.1.10"])
      s.add_dependency(%q<mpaas-project>.freeze, [">= 1.1.11"])
      s.add_dependency(%q<mpaas-template>.freeze, [">= 1.1.12"])
      s.add_dependency(%q<bundler>.freeze, ["~> 2.0"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3.2"])
    end
  else
    s.add_dependency(%q<mpaas-common>.freeze, [">= 1.1.18"])
    s.add_dependency(%q<mpaas-env>.freeze, [">= 1.1.10"])
    s.add_dependency(%q<mpaas-project>.freeze, [">= 1.1.11"])
    s.add_dependency(%q<mpaas-template>.freeze, [">= 1.1.12"])
    s.add_dependency(%q<bundler>.freeze, ["~> 2.0"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.2"])
  end
end
