
# A complete download that doesn't have its download file yet; when it gets it,
# it will replace (eat?) any existing non-pupal Complete to become the sole
# non-pupal Complete.
# Note only one is allowed at a time, per the parent validation.
class Download::DwcArchive::PupalComplete < Download::DwcArchive::Complete

  private

  def save_file
    # Replace any older existing Complete
    complete_download = Download.where(
      type: 'Download::DwcArchive::Complete', project_id:
    ).first
    if complete_download.nil?
      if super # moved tmp file to file storage
        update_column(:type, 'Download::DwcArchive::Complete')
        return true
      end
    else
      # Replace it.
      begin
        Download.transaction do
          if super # moved tmp file to file storage
            complete_download.destroy!
            update_column(:type, 'Download::DwcArchive::Complete')
            return true
          end
        end
      rescue ActiveRecord::RecordNotDestroyed => e
        msg = "Destroy of complete download '#{complete_download.id}' failed, pupal download '#{id}' failed to eclose (should no longer exist)."
        # The older complete download remains, this one is gone: destroy of the
        # old one needs to be investigated.
        raise ActiveRecord::RecordNotDestroyed.new(msg, e.record)
      end
    end

    false
  end

  def self.project_api_access_token_destroyed
    # May not be necessary if the download doesn't include media extension, but
    # we're doing it anyway.
    Download::DwcArchive::PupalComplete.destroy_all
  end
end
