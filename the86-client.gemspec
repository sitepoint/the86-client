# -*- encoding: utf-8 -*-
require File.expand_path('../lib/the86-client/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Paul Annesley"]
  gem.email         = ["paul@annesley.cc"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "the86-client"
  gem.require_paths = ["lib"]
  gem.version       = The86::Client::VERSION

  gem.add_development_dependency "minitest"
  gem.add_development_dependency "guard"
  gem.add_development_dependency "guard-minitest"
end
