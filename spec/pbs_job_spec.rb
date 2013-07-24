require_relative 'support/spec_helper'

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
      stderr.must_equal <<-NO_NAME
No value provided for required arguments 'name'
NO_NAME
    end
  end
end