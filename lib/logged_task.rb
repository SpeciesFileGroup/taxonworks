module LoggedTask

  @@task_number = 0
  @@root_task_number = nil
  @@loggers = []

# @param [Array] args
# @param [Block] block
  def self.define(*args, &block)
    task_number = @@task_number += 1

    task_sym = "__LOGGED_ROOT_TASK_DETECTOR_#{task_number}".to_sym

    args[0] = { args.first => [] } if args.first.is_a?(Symbol)
    args[0].values[0].unshift(task_sym)

    task = Rake::Task.define_task(*args) do
      begin
        logger = TaskLogger.new(task.name)
        @@loggers << logger
        logger.info("Logged task #{task.name} started...")

        yield logger if block_given?

        logger.info("Logged task #{task.name} completed!")
        if task_number == @@root_task_number
          logger.info('All tasks completed. Dumping summary for each task...')
          @@loggers.each { | logger | logger.summary }
        end
      rescue => exception
        logger.summary
        logger.error("Logged task #{task.name} failed.", exception.backtrace)
        raise
      end
    end

    Rake::Task.define_task(task_sym) { @@root_task_number = task_number unless @@root_task_number }
  end

  class TaskLogger

    # @param [String] task_full_name
    def initialize(task_full_name)
      names = task_full_name.split(':')
      task_name = names.pop
      path = Rails.root.join('log', 'rake_tasks')

      FileUtils.mkdir_p(path)
      time = Time.now.strftime('%Y-%m-%d_%H%M%S.%N')
      @log_file = File.new(path.join("#{time}-#{names.join(".")}.#{task_name}.log"), 'w')
      @warns_and_errors = []
      @task_full_name = task_full_name
    end

    # @param [String] msg
    # @param [Object] object
    def info(msg, object=nil)
      write("[INFO]#{time_str}: #{msg}", object)
    end

    # @param [String] msg
    # @param [Object] object
    def warn(msg, object=nil)
      msg = "[WARN]#{time_str}: #{msg}"
      @warns_and_errors << { msg:, color: :yellow}
      write(msg, object, :yellow)
    end

    # @param [String] msg
    # @param [Object] object
    def error(msg, object=nil)
      msg = "[ERROR]#{time_str}: #{msg}"
      @warns_and_errors << { msg:, color: :red }
      write(msg, object, :red)
    end

    def summary
      # TODO: Write all warnings and errors together
      write("=== Summary of warnings and errors for task #{@task_full_name} ===", nil)
      if @warns_and_errors.empty?
        write('(NONE)', nil)
      else
        @warns_and_errors.each { | e | write(e[:msg], nil, e[:color]) }
      end
      write('', nil)
    end

    private

    # @return [String]
    def time_str
      Time.now.strftime('%Y-%m-%d %H:%M:%S.%3N')
    end

    # @param [String] msg
    # @param [Object] object
    # @param [Term::ANSIColor] color
    def write(msg, object, color=nil)
      write_file(@log_file, msg, object, true)
      @log_file.fsync

      if !color.nil?
        msg = Rainbow(msg).send(:color)
      end

      write_file($stdout, msg, object, false)
    end

    # @param [File] fd
    # @param [String] msg
    # @param [Object] object
    # @param [Boolean] plain
    def write_file(fd, msg, object, plain)
      fd.puts msg
      fd.puts object.ai(plain: plain) unless object.nil?
    end
  end
end
