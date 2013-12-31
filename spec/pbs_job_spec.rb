require_relative 'support/spec_helper'

require "date"
require 'tmpdir'

require_relative '../lib/pbs_job'

NAME = 'test_job'
EMAIL_ADDRESS = 'email@address'
TODAY = Date.today
MONTH = Date::MONTHNAMES[TODAY.month].downcase
JOB_ROOT = "#{NAME}.#{MONTH}#{TODAY.day}_#{TODAY.year}"
QSUB_SCRIPT = "#{JOB_ROOT}/job.qsub"
PBS_SCRIPT = "#{JOB_ROOT}/job.pbs"
TASK = "#{JOB_ROOT}/task"
RESULTS = "#{JOB_ROOT}/results"
STREAMS = "#{JOB_ROOT}/streams"

describe 'pbs_job' do

  HELP = <<-HELP
Commands:
  pbs_job help [COMMAND]                    # Describe available commands or ...
  pbs_job new NAME EMAIL_ADDRESS [OPTIONS]  # Creates a new PBS job with the ...

HELP
  SUCCESSFUL_OUTPUT = <<-OUT
\e[1m\e[32m      create\e[0m  #{JOB_ROOT}
\e[1m\e[32m      create\e[0m  #{QSUB_SCRIPT}
\e[1m\e[32m       chmod\e[0m  #{QSUB_SCRIPT}
\e[1m\e[32m      create\e[0m  #{PBS_SCRIPT}
\e[1m\e[32m       chmod\e[0m  #{PBS_SCRIPT}
\e[1m\e[32m      create\e[0m  #{TASK}
\e[1m\e[32m       chmod\e[0m  #{TASK}
\e[1m\e[32m      create\e[0m  #{STREAMS}
\e[1m\e[32m      create\e[0m  #{RESULTS}
OUT

  it 'prints usage and options without arguments' do
    pbs_job
    stdout.must_equal HELP
  end
  it 'prints help' do
    pbs_job 'help'
    stdout.must_equal HELP
  end

  describe 'new' do
    it 'prints help' do
      pbs_job 'help new'
      gen_help = <<-GEN_HELP
Usage:
  pbs_job new NAME EMAIL_ADDRESS [OPTIONS]

Options:
  r, [--link-results=LINK_RESULTS]          # Directory to which to redirect results
  s, [--script=SCRIPT]                      # Type of script to make the task script
                                            # Default: bash
  w, [--task-working-dir=TASK_WORKING_DIR]  # Working directory in which to run task
GEN_HELP

    stdout[0..gen_help.length-1].must_equal gen_help
    end
    it 'requires name argument' do
      pbs_job 'new'
      stderr.must_equal "No value provided for required arguments 'name', 'email_address'\n"
    end
    it 'requires an email argument' do
      pbs_job "new #{NAME}"
      stderr.must_equal "No value provided for required arguments 'email_address'\n"
    end
    it 'creates a file structure for job components' do
      in_tmp_dir do
        pbs_job "new #{NAME} #{EMAIL_ADDRESS}"

        stdout.must_equal SUCCESSFUL_OUTPUT
        File.directory?(JOB_ROOT).must_equal true
        check_script QSUB_SCRIPT
        check_script PBS_SCRIPT
        check_script TASK
        File.directory?(RESULTS).must_equal true
        File.directory?(STREAMS).must_equal true
      end
    end
  end
  describe 'script type option' do
    it '--script allows specification of the script type of task' do
      in_tmp_dir do
        pbs_job "new #{NAME} #{EMAIL_ADDRESS} --script=bash"

        stdout.must_equal SUCCESSFUL_OUTPUT
        File.directory?(JOB_ROOT).must_equal true
        check_script QSUB_SCRIPT
        check_script PBS_SCRIPT
        check_script TASK
        File.directory?(RESULTS).must_equal true
        File.directory?(STREAMS).must_equal true
      end
    end
  end
  describe 'results link option' do
    it '--link-results allows redirection of results' do
      linked_results = '/scratch/results'
      in_tmp_dir do
        pbs_job "new #{NAME} #{EMAIL_ADDRESS} --link-results=#{linked_results}"

        stdout.must_equal SUCCESSFUL_OUTPUT
        File.directory?(JOB_ROOT).must_equal true
        check_script QSUB_SCRIPT
        check_script PBS_SCRIPT
        check_script TASK
        File.symlink?(RESULTS).must_equal true
        File.readlink(RESULTS).must_equal linked_results
        File.directory?(STREAMS).must_equal true
      end
    end
  end

  def check_script(script_path)
    File.file?(script_path).must_equal true
    File.executable?(script_path).must_equal true
  end
end

describe PbsJob::PbsJob do
  it '#start returns the job root directory as the first element of a list' do
    args = ['new', NAME, EMAIL_ADDRESS]
    in_tmp_dir do
      patient = nil
      quietly do
        patient = File.basename(PbsJob::PbsJob.start(args).first)
      end
      patient.must_equal JOB_ROOT
    end
  end
end

def quietly
  $stdout.flush
  $stderr.flush
  previous_stdout = $stdout.dup
  previous_stderr = $stderr.dup
  begin
    $stdout.reopen('/home/vagrant/temp/temp.out', 'w')
    $stderr.reopen('/home/vagrant/temp/temp.err', 'w')
    yield
  ensure
    $stdout.reopen(previous_stdout)
    $stderr.reopen(previous_stderr)
  end
end

def in_tmp_dir
  Dir.mktmpdir do |dir|
    Dir.chdir dir
    yield dir if block_given?
  end
end
