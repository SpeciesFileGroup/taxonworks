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
      render json: {
        base: 'Failed to save profile!'
      }, status: :unprocessable_content
    end
  end

  def save_coldp_settings
    attrs = params.permit(:col_publication_reminder).to_h

    if @project.save_coldp_settings(attrs)
      render json: @project.coldp_preferences_for_vue(sessions_current_user)
    else
      render json: {
        base: 'Failed to save settings!'
      }, status: :unprocessable_content
    end
  end

  def destroy_profile
    if @project.destroy_coldp_profile(params[:otu_id].to_i)
      render json: @project.coldp_preferences_for_vue(sessions_current_user)
    else
      render json: {
        base: 'Failed to destroy profile!'
      }, status: :unprocessable_content
    end
  end

  def validate_metadata
    metadata_yaml = params[:metadata_yaml]

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
    status = ::Export::Coldp::Files::Taxon::IRI_MAP.map do |key, uri|
      predicate = Predicate.where(project_id: @project.id, uri: uri).first
      {
        key: key.to_s,
        uri: uri,
        exists: predicate.present?,
        predicate_id: predicate&.id,
        predicate_name: predicate&.name
      }
    end

    render json: status
  end

  def create_missing_predicates
    created = []

    ::Export::Coldp::Files::Taxon::IRI_MAP.each do |key, uri|
      next if Predicate.where(project_id: @project.id, uri: uri).exists?

      predicate = Predicate.create!(
        name: "ColDP #{key}",
        definition: "ColDP controlled vocabulary term for #{key} (#{uri})",
        uri: uri,
        project: @project,
        by: sessions_current_user_id
      )
      created << { key: key.to_s, uri: uri, predicate_id: predicate.id }
    end

    render json: { created: created }
  end

  def create_predicate
    key = params[:key]&.to_sym
    uri = ::Export::Coldp::Files::Taxon::IRI_MAP[key]

    if uri.nil?
      render json: { error: "Unknown term: #{key}" }, status: :unprocessable_content
      return
    end

    if Predicate.where(project_id: @project.id, uri: uri).exists?
      render json: { error: "Predicate for #{key} already exists" }, status: :unprocessable_content
      return
    end

    predicate = Predicate.create!(
      name: "ColDP #{key}",
      definition: "ColDP controlled vocabulary term for #{key} (#{uri})",
      uri: uri,
      project: @project,
      by: sessions_current_user_id
    )

    render json: { key: key.to_s, uri: uri, predicate_id: predicate.id }
  end

  def missing_otus_count
    otu_id = params[:otu_id].to_i
    otu = Otu.where(project_id: @project.id).find(otu_id)

    taxon_name = otu.taxon_name
    if taxon_name.nil?
      render json: { all_without: 0, all_with: 0, valid_without: 0, valid_with: 0,
                     valid_children_without: 0, valid_children_with: 0,
                     invalid_without: 0, invalid_with: 0,
                     invalid_children_without: 0, invalid_children_with: 0 }
      return
    end

    descendants = taxon_name.self_and_descendants
    children = taxon_name.children

    render json: {
      all_without: descendants.without_otus.count,
      all_with: descendants.with_otus.count,
      valid_without: descendants.that_is_valid.without_otus.count,
      valid_with: descendants.that_is_valid.with_otus.count,
      valid_children_without: children.that_is_valid.without_otus.count,
      valid_children_with: children.that_is_valid.with_otus.count,
      invalid_without: descendants.that_is_invalid.without_otus.count,
      invalid_with: descendants.that_is_invalid.with_otus.count,
      invalid_children_without: children.that_is_invalid.without_otus.count,
      invalid_children_with: children.that_is_invalid.with_otus.count
    }
  end

  def fetch_clb_metadata
    dataset_id = params[:checklistbank_dataset_id]

    if dataset_id.blank?
      render json: { error: 'checklistbank_dataset_id is required' }, status: :unprocessable_content
      return
    end

    begin
      metadata = Colrapi.dataset(dataset_id: dataset_id.to_i)

      exclude_fields = %w[created createdBy modified modifiedBy attempt imported lastImportAttempt lastImportState size label citation private platform]
      metadata = metadata.except(*exclude_fields)

      render json: { metadata_yaml: metadata.to_yaml }
    rescue => e
      render json: { error: e.message }, status: :unprocessable_content
    end
  end

  def checklistbank_citation
    dataset_id = params[:checklistbank_dataset_id]

    if dataset_id.blank?
      render json: { error: 'checklistbank_dataset_id is required' }, status: :unprocessable_content
      return
    end

    begin
      metadata = Colrapi.dataset(dataset_id: dataset_id.to_i)
      render json: { citation: metadata['citation'], doi: metadata['doi'] }
    rescue => e
      render json: { error: e.message }, status: :unprocessable_content
    end
  end

  def checklistbank_issues
    dataset_id = params[:checklistbank_dataset_id]

    if dataset_id.blank?
      render json: { error: 'checklistbank_dataset_id is required' }, status: :unprocessable_content
      return
    end

    begin
      response = Colrapi.importer(dataset_id_filter: dataset_id.to_i, state: 'finished', limit: 1)
      results = response['result'] || []
      if results.any?
        render json: results.first
      else
        render json: {}
      end
    rescue => e
      render json: { error: e.message }, status: :unprocessable_content
    end
  end

  def search_datasets
    q = params[:q]

    if q.blank?
      render json: []
      return
    end

    begin
      response = Colrapi.dataset(q: q, limit: 10)
      results = (response['result'] || []).map do |d|
        { key: d['key'], alias: d['alias'], title: d['title'] }
      end
      render json: results
    rescue => e
      render json: { error: e.message }, status: :unprocessable_content
    end
  end

  def issue_vocab
    begin
      response = Colrapi.vocab(term: 'issue')
      render json: response
    rescue => e
      render json: { error: e.message }, status: :unprocessable_content
    end
  end

  private

  def set_project
    @project = Project.find(sessions_current_project_id)
    @recent_object = @project
  end
end
