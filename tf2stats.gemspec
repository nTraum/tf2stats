# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tf2stats/version'

Gem::Specification.new do |gem|
  gem.name          = "tf2stats"
  gem.version       = Tf2Stats::VERSION
  gem.authors       = ["Philipp Preß"]
  gem.email         = ["philipp.press@googlemail.com"]
  gem.description   = %q{Access statistics such as kills, deaths, damage, heals etc. from your matches.}
  gem.summary       = %q{Log File Parser for Team Fortress 2 matches, collects various statistics.}
  gem.homepage      = "https://github.com/nTraum/tf2stats"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end