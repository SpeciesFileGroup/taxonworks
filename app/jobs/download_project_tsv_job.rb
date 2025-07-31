class DownloadProjectTsvJob < ApplicationJob
  queue_as :project_download

  def max_run_time
    1.hour
  end

  def max_attempts
    2
  end

  def perform(target_project, download)
    begin
      download.source_file_path = ::Export::ProjectData::Tsv.export(target_project)
      download.save!
      download
    rescue => ex
      ExceptionNotifier.notify_exception(ex,
        data: { project: target_project&.id, download: download&.id&.to_s }
      )
      raise
    end
  end
end
