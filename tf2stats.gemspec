# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tf2stats/version'

Gem::Specification.new do |gem|
  gem.name          = "tf2stats"
  gem.version       = Tf2Stats::VERSION
  gem.authors       = ["Philipp Preß"]
  gem.email         = ["philipp.press@googlemail.com"]
  gem.description   = %q{Log Parser for Team Fortress 2 matches}
  gem.summary       = %q{Log Parser for Team Fortress 2 matches}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
