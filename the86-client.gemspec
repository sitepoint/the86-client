# -*- encoding: utf-8 -*-
require File.expand_path('../lib/the86-client/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Paul Annesley"]
  gem.email         = ["paul@sitepoint.com"]
  gem.description   = %q{Client for The 86 conversation API server}
  gem.summary       = %q{Exposes The 86 conversation API server as an object model.}
  gem.homepage      = "https://github.com/sitepoint/the86-client"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^spec/})
  gem.name          = "the86-client"
  gem.require_paths = ["lib"]
  gem.version       = The86::Client::VERSION

  ##
  # Runtime dependencies.

  # Faraday: HTTP client.
  gem.add_runtime_dependency "faraday"
  gem.add_runtime_dependency "faraday_middleware"
  gem.add_runtime_dependency "hashie"

  # Addressable: URI implementation.
  gem.add_runtime_dependency "addressable"
  gem.add_runtime_dependency "rack"

  # Virtus: declare attributes on plain Ruby objects.
  gem.add_runtime_dependency "virtus"

  ##
  # Development dependencies.

  # Guard: watch files, trigger commands
  gem.add_development_dependency "guard"
  gem.add_development_dependency "guard-minitest"

  # MiniTest: unit test / spec library.
  gem.add_development_dependency "minitest", "~> 4.6"
  gem.add_development_dependency "ansi"
  gem.add_development_dependency "turn"

  # Rake: build tool.
  gem.add_development_dependency "rake"

  # WebMock: HTTP request stubs and expectations.
  gem.add_development_dependency "webmock"

end
