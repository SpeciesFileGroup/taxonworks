# One per (project, otu_id) pair. Each corresponds to a COLDP profile.
# The `request` column stores the otu_id to distinguish per-profile downloads.
class Download::Coldp::Complete < Download::Coldp
  attribute :name, default: -> { "coldp_complete_#{DateTime.now}.zip" }
  attribute :description, default: 'A ColDP archive of the complete TaxonWorks export for a given OTU'
  attribute :filename, default: -> { "coldp_complete_#{DateTime.now}.zip" }
  attribute :expires, default: -> { 1.month.from_now }
  attribute :is_public, default: -> { 1 }

  before_save :sync_expires_with_preferences
  after_save :build, unless: :ready?

  validates :type, uniqueness: {
    scope: [:project_id, :request],
    conditions: -> { unexpired },
    message: ->(record, data) {
      "Only one #{record.type} per OTU is allowed. Destroy the old version first."
    }
  }

  def self.api_buildable?
    true
  end

  # @return [Download] the complete download to be served
  def self.process_complete_download_request(project, otu_id)
    download = Download.where(
      type: 'Download::Coldp::Complete',
      project_id: project.id,
      request: otu_id.to_s
    ).first

    return nil if download.nil?

    if download.ready?
      profile = project.coldp_profile_for(otu_id.to_i)
      max_age = profile&.fetch('max_age', nil)
      download_age = Time.current - download.created_at
      by_id = Current.user_id || profile&.fetch('default_user_id', nil)

      if max_age && download_age.to_f / 1.day > max_age
        Download::Coldp::PupalComplete.create(
          by: by_id,
          project_id: project.id,
          request: otu_id.to_s
        )
      end

      download.increment!(:times_downloaded)
      return download
    else
      raise TaxonWorks::Error, 'The existing download is not ready yet'
    end
  end

  private

  def build
    otu = Otu.where(project_id:).find_by(id: request.to_i)
    raise TaxonWorks::Error, "OTU #{request} not found" unless otu

    profile = project.coldp_profile_for(request.to_i) || {}
    prefer_unlabelled = profile.fetch('prefer_unlabelled_otus', false)

    ::ColdpCreateDownloadJob.perform_later(
      otu,
      self,
      prefer_unlabelled_otus: prefer_unlabelled
    )
  end

  def sync_expires_with_preferences
    profile = project.coldp_profile_for(request.to_i)
    max_age = profile&.fetch('max_age', nil)
    return if max_age.nil?

    self.expires = Time.zone.now + max_age.to_f.days + 7.days + 1.day
  end

  def self.project_api_access_token_destroyed
    Download::Coldp::Complete.destroy_all
  end
end
