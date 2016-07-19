module LoggedTask

  @@task_number = 0
  @@root_task_number = nil

  Rake::Task.define_task(:__LOGGED_ROOT_TASK) { @@root_task_number = @@task_number }

  def self.define(*args, &block)
    task_number = @@task_number += 1

    args[0] = { args.first => [] } if args.first.is_a?(Symbol)
    args[0].values[0].unshift(:__LOGGED_ROOT_TASK)

    task = Rake::Task.define_task(*args) do
      begin
        logger = TaskLogger.new(task.name) # TODO: Think about using a single logger (and hence a single file)
        logger.info("Logged task #{task.name} started...")

        yield logger if block_given?

        logger.info("Logged task #{task.name} completed!")
      rescue => e
        # TODO: Print summary and extended stack trace for this task only
        raise
      end
      puts "Task number #{task_number} completed!"
      if task_number == @@root_task_number
        # TODO: Print summary for all tasks executed
      end
    end
  end

  private

  class TaskLogger

    def initialize(task_full_name)
      names = task_full_name.split(":")
      task_name = names.pop
      path = Rails.root.join("log", "rake_tasks")

      FileUtils.mkdir_p(path)
      time = Time.now.strftime('%Y-%m-%d_%H%M%S.%N')
      @log_file = File.new(path.join("#{time}-#{names.join(".")}.#{task_name}.log"), "w")
    end

    def info(msg, object=nil)
      write("[INFO]#{time_str}: #{msg}", object)
    end

    def warn(msg, object=nil)
      write("[WARN]#{time_str}: #{msg}", object, Term::ANSIColor.yellow)
    end

    def error(msg, object=nil)
      write("[ERROR]#{time_str}: #{msg}", object, Term::ANSIColor.red)
    end

    def summary
      # TODO: Write all warnings and errors together
    end

    private

    def time_str
      Time.now.strftime('%Y-%m-%d %H:%M:%S.%3N')
    end

    def write(msg, object, color=nil)
      write_file(@log_file, msg, object)
      @log_file.fsync

      msg = color + msg + Term::ANSIColor.clear unless color.nil?

      write_file($stdout, msg, object)
    end

    def write_file(fd, msg, object)
      fd.puts msg
      fd.puts object.ai unless object.nil?
    end

  end

end