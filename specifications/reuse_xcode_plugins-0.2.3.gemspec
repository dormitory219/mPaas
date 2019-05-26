# -*- encoding: utf-8 -*-
# stub: reuse_xcode_plugins 0.2.3 ruby lib

Gem::Specification.new do |s|
  s.name = "reuse_xcode_plugins".freeze
  s.version = "0.2.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "allowed_push_host" => "https://rubygems.org" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["\u{591c}\u{79b9}".freeze]
  s.bindir = "exe".freeze
  s.date = "2017-03-15"
  s.description = "Write a longer description or delete this line.".freeze
  s.email = ["me@yemingyu.com".freeze]
  s.executables = ["reuse_xcode_plugins".freeze]
  s.files = ["exe/reuse_xcode_plugins".freeze]
  s.homepage = "https://yemingyu.com".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.7.9".freeze
  s.summary = "Write a short summary, because Rubygems requires one.".freeze

  s.installed_by_version = "2.7.9" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.13"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_runtime_dependency(%q<colorize>.freeze, ["~> 0.8.1"])
      s.add_runtime_dependency(%q<inquirer>.freeze, ["~> 0.2.1"])
    else
      s.add_dependency(%q<bundler>.freeze, ["~> 1.13"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_dependency(%q<colorize>.freeze, ["~> 0.8.1"])
      s.add_dependency(%q<inquirer>.freeze, ["~> 0.2.1"])
    end
  else
    s.add_dependency(%q<bundler>.freeze, ["~> 1.13"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_dependency(%q<colorize>.freeze, ["~> 0.8.1"])
    s.add_dependency(%q<inquirer>.freeze, ["~> 0.2.1"])
  end
end
