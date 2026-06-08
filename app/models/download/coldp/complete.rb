# One per (project, otu_id) pair. Each corresponds to a COLDP profile.
# The `request` column stores the otu_id to distinguish per-profile downloads.
class Download::Coldp::Complete < Download::Coldp
  include Shared::CompleteDownload

  attribute :name, default: -> { "coldp_complete_#{DateTime.now}.zip" }
  attribute :description, default: 'A ColDP archive of the complete TaxonWorks export for a given OTU'
  attribute :filename, default: -> { "coldp_complete_#{DateTime.now}.zip" }

  validates :type, uniqueness: {
    scope: [:project_id, :request],
    conditions: -> { unexpired },
    message: ->(record, data) {
      "Only one #{record.type} per OTU is allowed. Destroy the old version first."
    }
  }

  def self.complete_download_required_params
    [:otu_id]
  end

  def self.complete_download_lookup_params(params)
    { request: params[:otu_id].to_s }
  end

  def self.complete_download_access_authorized?(project, params)
    profile = project.coldp_profile_for(params[:otu_id].to_i)
    !!(profile && profile['is_public'])
  end

  def self.complete_download_max_age(project, params)
    project.coldp_profile_for(params[:otu_id].to_i)&.fetch('max_age', nil)
  end

  def self.complete_download_default_user_id(project, params)
    project.coldp_profile_for(params[:otu_id].to_i)&.fetch('default_user_id', nil)
  end

  def self.project_api_access_token_destroyed
    Download::Coldp::Complete.destroy_all
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
end
