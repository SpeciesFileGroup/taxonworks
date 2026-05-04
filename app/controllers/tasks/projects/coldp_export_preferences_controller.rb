class Tasks::Projects::ColdpExportPreferencesController < ApplicationController
  include TaskControllerConfiguration

  before_action :require_project_administrator_sign_in
  before_action :set_project

  def index
    # vue app
  end

  def preferences
    render json: @project.coldp_preferences_for_vue(sessions_current_user)
  end

  def save_profile
    profile_attrs = params.permit(
      :otu_id, :checklistbank_dataset_id, :is_public,
      :default_user_id, :max_age, :metadata_yaml,
      :maintain_metadata_in_checklistbank, :base_url,
      :fossil_extinct, :default_lifezone
    ).to_h

    if @project.save_coldp_profile(profile_attrs)
      render json: @project.coldp_preferences_for_vue(sessions_current_user)
    else
      render json: { error: @project.errors.full_messages.join('; ').presence || 'Failed to save profile' },
        status: :unprocessable_content
    end
  end

  def save_coldp_settings
    attrs = params.permit(:col_publication_reminder).to_h

    if @project.save_coldp_settings(attrs)
      render json: @project.coldp_preferences_for_vue(sessions_current_user)
    else
      render json: { error: @project.errors.full_messages.join('; ').presence || 'Failed to save settings' },
        status: :unprocessable_content
    end
  end

  def destroy_profile
    otu_id = params.permit(:otu_id)[:otu_id].to_i

    if @project.destroy_coldp_profile(otu_id)
      render json: @project.coldp_preferences_for_vue(sessions_current_user)
    else
      render json: { error: @project.errors.full_messages.join('; ').presence || 'Failed to destroy profile' },
        status: :unprocessable_content
    end
  end

  def validate_metadata
    metadata_yaml = params.permit(:metadata_yaml)[:metadata_yaml]

    if metadata_yaml.blank?
      render json: { errors: [] }
      return
    end

    begin
      YAML.safe_load(metadata_yaml)
      render json: { errors: [] }
    rescue Psych::SyntaxError => e
      render json: { errors: [e.message] }
    end
  end

  def controlled_vocabulary_status
    render json: ::Export::Coldp.controlled_vocabulary_status(@project)
  end

  def create_missing_predicates
    created = ::Export::Coldp.create_missing_predicates(@project, sessions_current_user_id)
    render json: { created: created }
  end

  def create_predicate
    key = params.permit(:key)[:key]&.to_sym
    predicate = ::Export::Coldp.create_predicate(@project, key, sessions_current_user_id)
    render json: { key: key.to_s, uri: predicate.uri, predicate_id: predicate.id }
  rescue ArgumentError, ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_content
  end

  def missing_otus_count
    otu_id = params.permit(:otu_id)[:otu_id].to_i
    otu = Otu.where(project_id: @project.id).find(otu_id)
    taxon_name = otu.taxon_name

    valid_without = taxon_name.nil? ? 0 : taxon_name.self_and_descendants.that_is_valid.without_otus.count

    render json: { valid_without: valid_without }
  end

  def fetch_clb_metadata
    dataset_id = permitted_checklistbank_dataset_id
    return render_missing_dataset_id if dataset_id.blank?

    metadata = Vendor::Colrapi::Dashboard.dataset_metadata(dataset_id)
    render json: { metadata_yaml: metadata.to_yaml }
  rescue Colrapi::Error => e
    render_colrapi_error(e)
  end

  def checklistbank_citation
    dataset_id = permitted_checklistbank_dataset_id
    return render_missing_dataset_id if dataset_id.blank?

    render json: Vendor::Colrapi::Dashboard.dataset_citation(dataset_id)
  rescue Colrapi::Error => e
    render_colrapi_error(e)
  end

  def checklistbank_issues
    dataset_id = permitted_checklistbank_dataset_id
    return render_missing_dataset_id if dataset_id.blank?

    render json: Vendor::Colrapi::Dashboard.dataset_issues(dataset_id)
  rescue Colrapi::Error => e
    render_colrapi_error(e)
  end

  def search_datasets
    query = params.permit(:q)[:q]

    if query.blank?
      render json: []
      return
    end

    render json: Vendor::Colrapi::Dashboard.search_datasets(query)
  rescue Colrapi::Error => e
    render_colrapi_error(e)
  end

  def issue_vocab
    render json: Vendor::Colrapi::Dashboard.issue_vocabulary
  rescue Colrapi::Error => e
    render_colrapi_error(e)
  end

  private

  def set_project
    @project = Project.find(sessions_current_project_id)
    @recent_object = @project
  end

  def permitted_checklistbank_dataset_id
    params.permit(:checklistbank_dataset_id)[:checklistbank_dataset_id]
  end

  def render_missing_dataset_id
    render json: { error: 'checklistbank_dataset_id is required' }, status: :unprocessable_content
  end

  def render_colrapi_error(error)
    render json: { error: error.message }, status: :service_unavailable
  end
end
