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
      :maintain_metadata_in_checklistbank, :base_url
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
    attrs = {
      'col_publication_reminder' => params[:col_publication_reminder] == true || params[:col_publication_reminder] == 'true'
    }

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

  def checklistbank_imports
    dataset_id = params[:checklistbank_dataset_id]

    if dataset_id.blank?
      render json: { error: 'checklistbank_dataset_id is required' }, status: :unprocessable_content
      return
    end

    begin
      response = Colrapi.importer(dataset_id_filter: dataset_id.to_i, state: 'finished', limit: 250)
      render json: response['result'] || []
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

  DUPLICATE_PRESETS = [
    { id: 'c1', text: 'ACC-ACC species (different authors)', section: 'species',
      params: { authorshipDifferent: true, minSize: 2, mode: 'STRICT', category: 'binomial', status: 'accepted' } },
    { id: 'c2', text: 'ACC-ACC species (same authors)', section: 'species',
      params: { authorshipDifferent: false, minSize: 2, mode: 'STRICT', category: 'binomial', status: 'accepted' } },
    { id: 'c5', text: 'ACC-SYN species (different accepted, different authors)', section: 'species',
      params: { authorshipDifferent: true, minSize: 2, mode: 'STRICT', acceptedDifferent: true, category: 'binomial', status: %w[accepted synonym] } },
    { id: 'c6', text: 'ACC-SYN species (different accepted, same authors)', section: 'species',
      params: { authorshipDifferent: false, minSize: 2, mode: 'STRICT', acceptedDifferent: true, category: 'binomial', status: %w[accepted synonym] } },
    { id: 'c7', text: 'ACC-SYN species (same accepted, same authors)', section: 'species',
      params: { authorshipDifferent: false, minSize: 2, mode: 'STRICT', acceptedDifferent: false, category: 'binomial', status: %w[accepted synonym] } },
    { id: 'c3', text: 'ACC-ACC infraspecies (different authors)', section: 'infraspecies',
      params: { authorshipDifferent: true, minSize: 2, mode: 'STRICT', category: 'trinomial', status: 'accepted' } },
    { id: 'c4', text: 'ACC-ACC infraspecies (same authors)', section: 'infraspecies',
      params: { authorshipDifferent: false, minSize: 2, mode: 'STRICT', category: 'trinomial', status: 'accepted' } },
    { id: 'c8', text: 'ACC-SYN infraspecies (different accepted, different authors)', section: 'infraspecies',
      params: { authorshipDifferent: true, minSize: 2, mode: 'STRICT', acceptedDifferent: true, category: 'trinomial', status: %w[accepted synonym] } },
    { id: 'c9', text: 'ACC-SYN infraspecies (different accepted, same authors)', section: 'infraspecies',
      params: { authorshipDifferent: false, minSize: 2, mode: 'STRICT', acceptedDifferent: true, category: 'trinomial', status: %w[accepted synonym] } },
    { id: 'c10', text: 'ACC-SYN infraspecies (same accepted, same authors)', section: 'infraspecies',
      params: { authorshipDifferent: false, minSize: 2, mode: 'STRICT', acceptedDifferent: false, category: 'trinomial', status: %w[accepted synonym] } },
    { id: 'b1', text: 'Identical order', section: 'higher_taxa',
      params: { minSize: 2, mode: 'STRICT', category: 'uninomial', rank: 'order', status: 'accepted' } },
    { id: 'b2', text: 'Identical superfamily', section: 'higher_taxa',
      params: { minSize: 2, mode: 'STRICT', category: 'uninomial', rank: 'superfamily', status: 'accepted' } },
    { id: 'b3', text: 'Identical family', section: 'higher_taxa',
      params: { minSize: 2, mode: 'STRICT', category: 'uninomial', rank: 'family', status: 'accepted' } },
    { id: 'b4', text: 'Identical genus', section: 'higher_taxa',
      params: { minSize: 2, mode: 'STRICT', category: 'uninomial', rank: 'genus', status: 'accepted' } },
    { id: 'b5', text: 'Identical subgenus', section: 'higher_taxa',
      params: { minSize: 2, mode: 'STRICT', category: 'uninomial', rank: 'subgenus', status: 'accepted' } }
  ].freeze

  def checklistbank_duplicates
    dataset_id = params[:checklistbank_dataset_id]

    if dataset_id.blank?
      render json: { error: 'checklistbank_dataset_id is required' }, status: :unprocessable_content
      return
    end

    begin
      base_url = Colrapi.base_url || 'https://api.checklistbank.org/'
      conn = Faraday.new(url: base_url, request: { params_encoder: Faraday::FlatParamsEncoder }) do |f|
        f.headers['Accept'] = 'application/json'
        f.adapter Faraday.default_adapter
      end

      results = DUPLICATE_PRESETS.map do |preset|
        response = conn.get("dataset/#{dataset_id}/duplicate/count", preset[:params])
        count = response.body.to_i
        {
          id: preset[:id],
          text: preset[:text],
          section: preset[:section],
          count: count,
          params: preset[:params]
        }
      rescue => e
        { id: preset[:id], text: preset[:text], section: preset[:section], count: nil, error: e.message }
      end

      render json: results
    rescue => e
      render json: { error: e.message }, status: :unprocessable_content
    end
  end

  def checklistbank_diff
    dataset_id = params[:checklistbank_dataset_id]
    attempt1 = params[:attempt1]
    attempt2 = params[:attempt2]

    if dataset_id.blank? || attempt1.blank? || attempt2.blank?
      render json: { error: 'checklistbank_dataset_id, attempt1, and attempt2 are required' }, status: :unprocessable_content
      return
    end

    begin
      base_url = Colrapi.base_url || 'https://api.checklistbank.org/'
      conn = Faraday.new(url: base_url) do |f|
        f.headers['Accept'] = 'text/plain'
        f.options.timeout = 30
        f.adapter Faraday.default_adapter
      end

      response = conn.get("dataset/#{dataset_id}/diff", { attempts: "#{attempt1}..#{attempt2}" })

      if response.success?
        render json: { diff: response.body }
      else
        render json: { error: "ChecklistBank returned status #{response.status}" }, status: :unprocessable_content
      end
    rescue Faraday::TimeoutError
      render json: { error: 'Request to ChecklistBank timed out' }, status: :gateway_timeout
    rescue => e
      render json: { error: e.message }, status: :unprocessable_content
    end
  end

  def bulk_set_extinct
    otu_id = params[:otu_id].to_i
    overwrite = params[:overwrite] == true || params[:overwrite] == 'true'

    BulkColdpExtinctJob.perform_later(
      @project.id,
      otu_id,
      sessions_current_user_id,
      overwrite:
    )

    render json: { status: 'Job enqueued' }
  end

  def bulk_set_lifezone
    otu_id = params[:otu_id].to_i
    value = params[:value]
    overwrite = params[:overwrite] == true || params[:overwrite] == 'true'

    BulkColdpLifezoneJob.perform_later(
      @project.id,
      otu_id,
      sessions_current_user_id,
      value:,
      overwrite:
    )

    render json: { status: 'Job enqueued' }
  end

  def bulk_load_issue_tags
    dataset_id = params[:checklistbank_dataset_id].to_i
    issue_keys = params[:issue_keys].presence

    BulkColdpIssueTagJob.perform_later(
      @project.id,
      dataset_id,
      sessions_current_user_id,
      issue_keys:
    )

    render json: { status: 'Job enqueued' }
  end

  def cleanup_issue_tags
    BulkColdpIssueCleanupJob.perform_later(
      @project.id,
      sessions_current_user_id
    )

    render json: { status: 'Job enqueued' }
  end

  def coldp_issue_keywords
    keywords = Keyword.where(project_id: @project.id)
      .where('name LIKE ?', 'COLDP: %')
      .left_joins(:tags)
      .group('controlled_vocabulary_terms.id')
      .select('controlled_vocabulary_terms.id, controlled_vocabulary_terms.name, COUNT(tags.id) AS tag_count')

    render json: keywords.map { |k| { id: k.id, name: k.name, tag_count: k.tag_count } }
  end

  private

  def set_project
    @project = Project.find(sessions_current_project_id)
    @recent_object = @project
  end
end
