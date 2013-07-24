require_relative 'support/spec_helper'

require "date"
require 'tmpdir'

describe 'pbs_job' do

  HELP = <<-HELP
Commands:
  pbs_job generate NAME EMAIL_ADDRESS  # Generates a new PBS job with the nam...
  pbs_job help [COMMAND]               # Describe available commands or one s...

HELP

  it 'prints usage and options without arguments' do
    pbs_job
    stdout.must_equal HELP
  end
  it 'prints help' do
    pbs_job 'help'
    stdout.must_equal HELP
  end

  describe 'generate' do
    it 'prints help' do
      pbs_job 'help generate'
      stdout.must_equal <<-GEN_HELP
Usage:
  pbs_job generate NAME EMAIL_ADDRESS

Generates a new PBS job with the name NAME and arranges for PBS alerts to be sent to EMAIL_ADDRESS
GEN_HELP
    end
    it 'requires name argument' do
      pbs_job 'generate'
      stderr.must_equal "No value provided for required arguments 'name', 'email_address'\n"
    end
    it 'requires an email argument' do
      pbs_job 'generate name'
      stderr.must_equal "No value provided for required arguments 'email_address'\n"
    end
    it 'creates a file structure for job components' do
      name = 'test_job'
      email_address = 'email@address'
      today = Date.today
      month = Date::MONTHNAMES[today.month].downcase
      job_root = "#{name}.#{month}#{today.day}_#{today.year}"
      qsub_script = "#{job_root}/job.qsub"
      pbs_script = "#{job_root}/job.pbs"
      task = "#{job_root}/task"
      results = "#{job_root}/results"
      streams = "#{job_root}/streams"

      in_tmp_dir do
        pbs_job "generate #{name} #{email_address}"
        stdout.must_equal <<-DIR
\e[1m\e[32m      create\e[0m  #{job_root}
\e[1m\e[32m      create\e[0m  #{qsub_script}
\e[1m\e[32m      create\e[0m  #{pbs_script}
\e[1m\e[32m      create\e[0m  #{task}
\e[1m\e[32m      create\e[0m  #{results}
\e[1m\e[32m      create\e[0m  #{streams}
DIR
        File.directory?(job_root).must_equal true
        File.file?(qsub_script).must_equal true
        File.file?(pbs_script).must_equal true
        File.file?(task).must_equal true
        File.directory?(results).must_equal true
        File.directory?(streams).must_equal true
      end
    end
  end

  def in_tmp_dir
    Dir.mktmpdir do |dir|
      Dir.chdir dir
      yield dir if block_given?
    end
  end
end