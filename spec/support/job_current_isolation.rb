# Make inline job execution in tests simulate a clean worker thread/process.
# This ensures jobs don't inherit Current.user_id, Current.project_id, etc.
# from the caller's thread, matching production worker behavior.
#
if Rails.env.test?
  module JobIsolationHelpers
    def with_job_isolation
      # Save all contexts
      previous_current = Current.attributes
      previous_locale = I18n.locale

      # Reset to job-like state
      Current.reset
      I18n.locale = I18n.default_locale

      yield
    ensure
      # Restore test contexts
      previous_current.each { |k, v| Current.send("#{k}=", v) }
      I18n.locale = previous_locale
    end
  end


  # ActiveJob isolation
  # This covers:
  # * perform_enqueued_jobs (which calls perform_now)
  # * any direct SomeJob.perform_now in specs
  #
  module TestIsolationForActiveJob
    include JobIsolationHelpers

    def perform_now(*args, **kwargs, &blk)
      with_job_isolation { super }
    end
  end

  ActiveSupport.on_load(:after_initialize) do
    # Prepend to ALL ActiveJob jobs (including ApplicationJob subclasses)
    ActiveJob::Base.prepend(TestIsolationForActiveJob)
  end


  # Delayed::Job isolation
  # This covers:
  # * Delayed::Worker.new.work_off
  #
  module TestIsolationForDelayedJob
    include JobIsolationHelpers

    def work_off(*args, **kwargs, &blk)
      with_job_isolation { super }
    end
  end

  Delayed::Worker.prepend(TestIsolationForDelayedJob)

end
