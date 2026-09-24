# A complete download that doesn't have its download file yet; when it gets it,
# it will replace any existing non-pupal Complete (for the same OTU) to become
# the sole non-pupal Complete.
class Download::Coldp::PupalComplete < Download::Coldp::Complete

  private

  def save_file
    complete_download = Download.where(
      type: 'Download::Coldp::Complete',
      project_id:,
      request:
    ).first

    if complete_download.nil?
      if super
        update_column(:type, 'Download::Coldp::Complete')
        return true
      end
    else
      begin
        Download.transaction do
          if super
            complete_download.destroy!
            update_column(:type, 'Download::Coldp::Complete')
            return true
          end
        end
      rescue ActiveRecord::RecordNotDestroyed => e
        msg = "Destroy of complete download '#{complete_download.id}' failed, " \
              "pupal download '#{id}' failed to eclose (should no longer exist)."
        raise ActiveRecord::RecordNotDestroyed.new(msg, e.record)
      end
    end

    false
  end

  def self.project_api_access_token_destroyed
    Download::Coldp::PupalComplete.destroy_all
  end
end
