# -*- encoding: utf-8 -*-
# stub: mpaas 5.0.4 ruby lib

Gem::Specification.new do |s|
  s.name = "mpaas".freeze
  s.version = "5.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["shifei.wkp".freeze]
  s.date = "2019-04-03"
  s.description = "mpaas \u{81ea}\u{52a8}\u{89e3}\u{6790} mpaas \u{76f8}\u{5173}\u{4f9d}\u{8d56}\u{ff0c}\u{7ba1}\u{7406} xcode \u{5de5}\u{7a0b}".freeze
  s.email = ["shifei.wkp@antfin.com".freeze]
  s.homepage = "https://tech.antfin.com/products/MPAAS".freeze
  s.required_ruby_version = Gem::Requirement.new(">= 2.3".freeze)
  s.rubygems_version = "2.7.9".freeze
  s.summary = "mpaas \u{547d}\u{4ee4}\u{884c}\u{5de5}\u{5177}".freeze

  s.installed_by_version = "2.7.9" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<mpaas-common>.freeze, [">= 1.1.18"])
      s.add_runtime_dependency(%q<mpaas-core>.freeze, [">= 1.1.27"])
      s.add_runtime_dependency(%q<mpaas-env>.freeze, [">= 1.1.10"])
      s.add_runtime_dependency(%q<mpaas-project>.freeze, [">= 1.1.11"])
      s.add_runtime_dependency(%q<mpaas-template>.freeze, [">= 1.1.12"])
      s.add_runtime_dependency(%q<mpaas-xcplugin>.freeze, [">= 1.0.6"])
      s.add_development_dependency(%q<bundler>.freeze, ["~> 2.0"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.2"])
      s.add_development_dependency(%q<rspec-command>.freeze, [">= 0"])
    else
      s.add_dependency(%q<mpaas-common>.freeze, [">= 1.1.18"])
      s.add_dependency(%q<mpaas-core>.freeze, [">= 1.1.27"])
      s.add_dependency(%q<mpaas-env>.freeze, [">= 1.1.10"])
      s.add_dependency(%q<mpaas-project>.freeze, [">= 1.1.11"])
      s.add_dependency(%q<mpaas-template>.freeze, [">= 1.1.12"])
      s.add_dependency(%q<mpaas-xcplugin>.freeze, [">= 1.0.6"])
      s.add_dependency(%q<bundler>.freeze, ["~> 2.0"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3.2"])
      s.add_dependency(%q<rspec-command>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<mpaas-common>.freeze, [">= 1.1.18"])
    s.add_dependency(%q<mpaas-core>.freeze, [">= 1.1.27"])
    s.add_dependency(%q<mpaas-env>.freeze, [">= 1.1.10"])
    s.add_dependency(%q<mpaas-project>.freeze, [">= 1.1.11"])
    s.add_dependency(%q<mpaas-template>.freeze, [">= 1.1.12"])
    s.add_dependency(%q<mpaas-xcplugin>.freeze, [">= 1.0.6"])
    s.add_dependency(%q<bundler>.freeze, ["~> 2.0"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.2"])
    s.add_dependency(%q<rspec-command>.freeze, [">= 0"])
  end
end
