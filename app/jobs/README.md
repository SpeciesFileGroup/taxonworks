# Jobs

* In *development* you can run queued jobs using `rails jobs:workoff`, or by leaving `rails jobs:work` running.

* In *production* jobs are run using `exe/delayed_job`, which sets up `jobs:work` with an explicit list of permitted job queue names. **If you add a job with a new queue name but do not add it to that list, it will not run in production.** 
  * There's a spec to catch this in case you forget: `spec/jobs/job_queue_registration_spec.rb`.
  * If a job is intentionally kept but not run in production, add its filename to `PRODUCTION_EXCLUDED_JOBS` in that spec.
