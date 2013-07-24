# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pbs_job/version'

Gem::Specification.new do |spec|
  spec.name          = "pbs_job"
  spec.version       = PbsJob::VERSION
  spec.authors       = ["Dustin Morrill"]
  spec.email         = ["morrill@ualberta.ca"]
  spec.description   = %q{PBS/Torque job generator}
  spec.summary       = %q{Creates a directory and file structure for a well organized PBS/Torque job.}
  spec.homepage      = "https://github.com/dmorrill10/pbs_job"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'thor', '~> 0.18.1'

  spec.add_development_dependency "bundler", '~> 1.3.5'
  spec.add_development_dependency 'bahia', '~> 0.7.2'
  spec.add_development_dependency 'rake', '~> 10.1.0'
  spec.add_development_dependency 'minitest', '~> 5.0.6'
  spec.add_development_dependency 'turn', '~> 0.9.6'
  spec.add_development_dependency 'awesome_print', '~> 1.1.0'
  spec.add_development_dependency 'pry-rescue', '~> 1.1.1'
  spec.add_development_dependency 'simplecov', '~> 0.7.1'
end
