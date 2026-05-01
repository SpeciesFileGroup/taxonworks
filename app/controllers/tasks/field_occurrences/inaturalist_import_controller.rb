require 'nasturtium'

class Tasks::FieldOccurrences::InaturalistImportController < ApplicationController
  include TaskControllerConfiguration

  OBSERVATION_LIMIT = 50

  def index
  end

  # POST /tasks/field_occurrences/inaturalist_import/submit.json
  def submit
    observation_ids = params[:observation_ids] || []

    if observation_ids.size > OBSERVATION_LIMIT
      render json: { error: "Maximum #{OBSERVATION_LIMIT} observations per submission." }, status: :unprocessable_entity
      return
    end

    results = ::Vendor::Nasturtium.by_observation_ids(observation_ids)

    candidate_uuids = results.filter_map { |r| r['uuid'] }
    existing_fo_by_uuid = existing_field_occurrences_by_uuid(candidate_uuids)

    import_images = params[:import_images] == true
    import_sounds = params[:import_sounds] == true

    new_results = results.reject { |r| existing_fo_by_uuid.key?(r['uuid']) }

    InaturalistImportJob.perform_later(
      results: new_results,
      project_id: sessions_current_project_id,
      user_id: sessions_current_user_id,
      match_otu_by_name: params[:match_otu_by_name] == true,
      use_community_taxon: params[:use_community_taxon] != false,
      import_images:,
      import_sounds:
    ) if new_results.any?

    submitted_ids = observation_ids.to_set
    found_ids = results.map { |r| r['id'].to_s }.to_set

    summary = build_summary(results, existing_fo_by_uuid, import_images:, import_sounds:) +
      (submitted_ids - found_ids).map { |id| { observation_id: id, status: 'not_found' } }

    render json: { summary: }
  end

  # GET /tasks/field_occurrences/inaturalist_import/recent.json
  def recent
    fos = FieldOccurrence
      .joins(:identifiers)
      .where(
        project_id: sessions_current_project_id,
        identifiers: { type: 'Identifier::Global::Uuid::InaturalistObservation' }
      )
      .order(created_at: :desc)
      .limit(10)
      .includes(:collecting_event, :identifiers, taxon_determinations: :otu)

    render json: { field_occurrences: fos.map { |fo| serialize_fo(fo) } }
  end

  private

  def existing_field_occurrences_by_uuid(uuids)
    return {} if uuids.blank?

    FieldOccurrence
      .joins(:identifiers)
      .where(
        project_id: sessions_current_project_id,
        identifiers: {
          type: 'Identifier::Global::Uuid::InaturalistObservation',
          identifier: uuids
        }
      )
      .pluck('field_occurrences.id', 'identifiers.identifier')
      .to_h { |fo_id, uuid| [uuid, fo_id] }
  end

  def build_summary(results, existing_fo_by_uuid, import_images:, import_sounds:)
    results.map do |r|
      uuid = r['uuid']
      existing_fo_id = existing_fo_by_uuid[uuid]
      {
        observation_id: r['id'].to_s,
        taxon_name: r.dig('community_taxon', 'name') || r.dig('taxon', 'name'),
        observer: r.dig('user', 'name').presence || r.dig('user', 'login'),
        observed_on: r['observed_on'],
        place_guess: r['place_guess'],
        status: existing_fo_id ? 'already_imported' : 'queued',
        field_occurrence_id: existing_fo_id,
        browse_url: existing_fo_id ? browse_field_occurrence_task_path(field_occurrence_id: existing_fo_id) : nil,
        image_count: import_images ? ::Vendor::Nasturtium.permitted_photos(r).size : nil,
        sound_count: import_sounds ? ::Vendor::Nasturtium.permitted_sounds(r).size : nil
      }
    end
  end

  def serialize_fo(fo)
    inat_identifier = fo.identifiers.find { |i| i.is_a?(Identifier::Global::Uuid::InaturalistObservation) }
    {
      id: fo.id,
      taxon_name: fo.taxon_determinations.first&.otu&.name,
      verbatim_locality: fo.collecting_event&.verbatim_locality,
      created_at: fo.created_at&.strftime('%Y-%m-%d %H:%M'),
      browse_url: browse_field_occurrence_task_path(field_occurrence_id: fo.id),
      inat_url: inat_identifier&.url
    }
  end

end
