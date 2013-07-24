require_relative 'support/spec_helper'

require "date"
require 'tmpdir'

describe 'pbs_job' do

  HELP = <<-HELP
Commands:
  pbs_job generate NAME   # Generates a new PBS job with the name NAME
  pbs_job help [COMMAND]  # Describe available commands or one specific command

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
  pbs_job generate NAME

Generates a new PBS job with the name NAME
GEN_HELP
    end
    it 'requires name argument' do
      pbs_job 'generate'
      stderr.must_equal "No value provided for required arguments 'name'\n"
    end
    it 'creates a directory for job components' do
      name = 'test_job'
      today = Date.today
      month = Date::MONTHNAMES[today.month].downcase
      x_directory = "#{name}.#{month}#{today.day}_#{today.year}"

      in_tmp_dir do
        pbs_job "generate #{name}"
        stdout.must_equal <<-DIR
\e[1m\e[32m      create\e[0m  #{x_directory}
DIR
        File.directory? x_directory
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