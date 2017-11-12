# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "qc/version"

Gem::Specification.new do |spec|
  spec.name          = "qc"
  spec.version       = Qc::VERSION
  spec.authors       = ["Jorge Manrubia"]
  spec.email         = ["jorge.manrubia@gmail.com"]

  spec.summary       = %q{Sync and run your QuantConnect backtests from the command line}
  spec.homepage      = "https://github.com/jorgemanrubia/qc"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = ['qc']
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "rest-client", "~> 2.0.2"
  spec.add_runtime_dependency "vcr", "~> 3.0.3"
  spec.add_runtime_dependency "webmock", "~> 3.1.0"
  spec.add_development_dependency "awesome_print"
  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
