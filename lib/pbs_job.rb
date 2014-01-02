require_relative "pbs_job/version"

require 'thor'
require 'date'

module PbsJob
  class New < Thor::Group
    include Thor::Actions

    STREAMS_DIR_NAME = 'streams'
    EXECUTABLE_PERMISSIONS = 0775

    argument :name, :desc => 'Name of the new job.'
    argument :email_address, :desc => 'Email to which to send PBS alerts.'

    class_option(
      :append_timestamp,
      {
        :desc => 'Append a date and timestamp to the job root directory name',
        :default => true,
        :aliases => 't',
        :type => :boolean
      }
    )
    class_option(
      :link_results,
      {
        :desc => 'Directory to which to redirect results',
        :default => nil,
        :aliases => 'r'
      }
    )
    class_option(
      :script,
      {
        :desc => 'Type of script to make the task script',
        :default => 'bash',
        :aliases => 's'
      }
    )
    class_option(
      :task_working_dir,
      {
        :desc => 'Working directory in which to run task',
        :default => File.expand_path('~'),
        :aliases => 'w'
      }
    )

    class_option(
      :walltime,
      {
        :desc => '#PBS -l walltime=72:00:00
    This is the maximum elapsed time that the job will be allowed to run, specified as hours, minutes and seconds in the form HH:MM:SS. If a job exceeds its walltime limit, it is killed by the system. It is best to overestimate the walltime to avoid a run being spoiled by early termination, however, an accurate walltime estimate will allow your job to be scheduled more effectively. It is best to design your code with a capability to write checkpoint data to a file periodically and to be able to restart from the time of the most recent checkpoint by reading that data. That way if the run reaches its walltime limit (or fails for some other reason), only a small fraction of the total computation will have to be redone in a subsequent run. (https://www.westgrid.ca/support/running_jobs)',
        :default => nil
      }
    )
    class_option(
      :mem,
      {
        :desc => '#PBS -l mem=2000mb
    The mem parameter should be an estimate of the total amount of memory required by the job. For parallel jobs, multiply the memory per process by the number of processes. Append units of MB or GB as appropriate. The value given must be an integer, so, for example, use mem=3584MB instead of mem=3.5GB (1 GB = 1024 MB) .
    Note: the mem parameter is not used on the large shared-memory machines. . . . (https://www.westgrid.ca/support/running_jobs)',
        :default => nil
      }
    )
    class_option(
      :nodes,
      {
        :desc => '#PBS -l nodes=4:ppn=2
    Use a combination of nodes and processors per node (ppn) to request the total number of processors needed. (https://www.westgrid.ca/support/running_jobs)',
        :default => nil
      }
    )
    class_option(
      :ppn,
      {
        :desc => '#PBS -l nodes=4:ppn=2
    Use a combination of nodes and processors per node (ppn) to request the total number of processors needed. (https://www.westgrid.ca/support/running_jobs)',
        :default => 1
      }
    )
    class_option(
      :pmem,
      {
        :desc => '#PBS -l pmem=2000mb
    Instead of specifying the total memory requirement of your job with the mem parameter . . ., you can specify a per process memory limit, pmem.  Note however, that mem and pmem are independent parameters, so, on some systems it may be necessary to specify both mem and pmem. (https://www.westgrid.ca/support/running_jobs)',
        :default => nil
      }
    )
    class_option(
      :procs,
      {
        :desc => '#PBS -l procs=8
    The procs resource request allows the scheduler to distribute the requested number of processors among any available nodes on the cluster.  This can reduce the waiting time in the input queue. . . .
    In using this resource request format, you are not guaranteed any specific number of processors per node.  As such, it is not appropriate for OpenMP programs or other multi-threaded programs, with rare exception.  For example, if you have a mixed MPI-OpenMP program in which you limit the number of threads per process to just one (OMP_NUM_THREADS=1) you could use procs.   In other cases, you may also have to combine procs with pmem to make sure that the scheduler does not assign too many of your processes to the same node. (https://www.westgrid.ca/support/running_jobs)',
        :default => nil
      }
    )

    def self.source_root
      File.expand_path('../../', __FILE__)
    end

    def gen_root() empty_directory(full_name) end
    def gen_qsub_script() create_script_from_template('job.qsub') end
    def gen_pbs_script() create_script_from_template('job.pbs') end
    def gen_task_script() create_script_from_template('task') end
    def gen_streams_dir() empty_directory(streams_path) end
    def gen_results_dir
      results_path = File.join full_name, 'results'
      if options[:link_results]
        create_link(results_path, options[:link_results])
      else
        empty_directory results_path
      end
    end

    private

    def file_path(script_name)
      File.join full_name, script_name
    end

    def create_file_from_template(file_name)
      template(
        "templates/#{file_name}.tt",
        file_path(file_name)
      )
    end

    def create_script_from_template(script_name)
      create_file_from_template script_name
      chmod file_path(script_name), EXECUTABLE_PERMISSIONS
    end

    # @returns [String] Name with date appended
    def full_name
      @full_name ||= if options[:append_timestamp]
        "#{name}.#{DateTime.now.strftime('%b%d_%Y.%Hh-%Mm-%Ss')}"
      else
        name
      end
    end

    def abs_job_root
      @abs_job_root ||= File.expand_path(full_name)
    end

    def streams_path
      @streams_path ||= File.join full_name, STREAMS_DIR_NAME
    end

    def abs_stream_prefix
      @abs_stream_prefix ||= File.join abs_job_root, STREAMS_DIR_NAME, full_name
    end
  end

  class PbsJob < Thor
    map 'n' => :new

    register(
      New,
      'new',
      'new NAME EMAIL_ADDRESS [OPTIONS]',
      "Creates a new PBS job with the name NAME and arranges for PBS alerts to be sent to EMAIL_ADDRESS, customized by OPTIONS"
    )
    tasks["new"].options = New.class_options
  end
end
