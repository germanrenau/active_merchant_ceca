# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name = %q{active_merchant_ceca}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = ["Pablo Herrero"]
  s.date = %q{2011-05-18}
  s.description = %q{Add support to ActiveMerchant for the CECA payment gateway, used by many banks in Spain}
  s.summary = "ActiveMerchant support for the CECA payment gateway"
  s.email = %q{pablodherrero@gmail.com}
  s.extra_rdoc_files = ['MIT-LICENSE', 'CHANGELOG', 'README.rdoc']
  s.homepage = %q{http://github.com/pabloh/active_merchant_ceca}
  s.rubygems_version = "1.3.7"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency("activemerchant", ">= 1.9.4")
  s.add_development_dependency("rspec", "~> 1.3.1")
  s.add_development_dependency("rspec-rails", "~> 1.3.3")
  s.add_development_dependency("money", "~> 3.5.4")
  s.add_development_dependency("actionpack", ">= 2.3.8")

end
