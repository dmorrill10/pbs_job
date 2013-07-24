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

  spec.add_dependency 'thor'

  spec.add_development_dependency "bundler"
  spec.add_development_dependency 'bahia'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'awesome_print'
  spec.add_development_dependency 'pry-rescue'
  spec.add_development_dependency 'simplecov'
end
