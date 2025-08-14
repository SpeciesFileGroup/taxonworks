# TaxonWorks Database Export with Docker Compose

## Overview

TaxonWorks allows exporting project data as PostgreSQL SQL dumps. When running TaxonWorks with Docker Compose, the export process uses DelayedJob for background processing, but the worker needs to be manually started.

## The Export Process

1. **User initiates export**: Through the UI at `/tasks/projects/data`, optionally providing a custom password
2. **Job is queued**: A `DownloadProjectSqlJob` is created and queued in the `delayed_jobs` table
3. **Worker processes job**: A delayed_job worker picks up the job and generates the SQL dump
4. **Download becomes available**: Once complete, the download link appears on the downloads page

## Starting the Export Worker

In a Docker Compose environment, the delayed_job worker is not automatically running. You need to start it manually:

### Option 1: Process all pending jobs (recommended for one-off exports)
```bash
docker compose exec app bundle exec rake jobs:workoff
```
This will process all pending jobs and then exit.

### Option 2: Start a persistent worker
```bash
docker compose exec -d app bundle exec rake jobs:work
```
This starts a worker in the background that will continue processing jobs.

## Monitoring the Export

### Check job status
```bash
docker compose exec app bundle exec rails runner 'dj = Delayed::Job.where("handler LIKE ?", "%DownloadProjectSqlJob%").last; if dj; puts "Status: #{dj.locked_by ? "Running" : "Queued"}"; puts "Attempts: #{dj.attempts}"; else; puts "No job found"; end'
```

### Check download status
```bash
docker compose exec app bundle exec rails runner 'dl = Download.last; puts "ID: #{dl.id} - Ready: #{dl.ready?} - Created: #{dl.created_at}"'
```

### Monitor logs
```bash
docker compose logs -f app | grep -i "download\|job\|worker"
```

### Continuous monitoring script
```bash
docker compose exec app bundle exec rails runner 'dl = Download.find(YOUR_DOWNLOAD_ID); loop { puts "#{Time.now}: Ready: #{dl.ready?}"; break if dl.ready?; sleep 10; dl.reload }'
```

## Troubleshooting

### Job stuck in queue
- Ensure a worker is running
- Check for errors in the `delayed_jobs` table:
  ```bash
  docker compose exec app bundle exec rails runner 'Delayed::Job.last(5).each { |j| puts "ID: #{j.id}, Attempts: #{j.attempts}, Error: #{j.last_error&.first(100)}" }'
  ```

### Export taking too long
- Large projects can take significant time to export
- The process includes dumping all project data, related community data, and resetting passwords
- Monitor the job with the commands above

### Finding your download
- Downloads are available at `/downloads/[ID]`
- The download ID is shown in the redirect after initiating the export
- Downloads expire after a set period (check `Download#expires` attribute)

## Important Notes

- All user passwords in the export are reset to either:
  - The custom password you provided, or
  - The default 'taxonworks' if no custom password was specified
- **Never expose exported databases publicly** due to the simplified passwords
- The export includes all project data and related community records (Sources, People, etc.)