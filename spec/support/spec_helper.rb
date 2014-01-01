require 'simplecov'
SimpleCov.start

require 'minitest/autorun'
require 'minitest/spec'

begin
  require 'awesome_print'
  module Minitest::Assertions
    def mu_pp(obj)
      obj.awesome_inspect
    end
  end
rescue LoadError
end

require 'bahia'

Bahia.project_directory = File.expand_path('../../../', __FILE__)
Bahia.command = File.join(Bahia.project_directory, 'bin', 'pbs_job')
Bahia.command_method = 'pbs_job'

class MiniTest::Spec
  include Bahia
end
