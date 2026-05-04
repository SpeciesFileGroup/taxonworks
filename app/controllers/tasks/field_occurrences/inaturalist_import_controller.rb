require 'nasturtium'

class Tasks::FieldOccurrences::InaturalistImportController < ApplicationController
  include TaskControllerConfiguration

  IMPORT_LIMIT = 50
  FIND_LIMIT = 200

  def index
  end

  # GET /tasks/field_occurrences/inaturalist_import/find.json
  def find
    observation_ids = params[:observation_ids] || []
    if observation_ids.size > FIND_LIMIT
      render json: { error: "Maximum #{FIND_LIMIT} observations per submission." }, status: :unprocessable_entity
      return
    end

    results = fetch_inat_results(observation_ids)
    return unless results

    existing_fo_by_uuid = existing_field_occurrences_for(results)
    fo_data = fetch_field_occurrence_data(existing_fo_by_uuid)
    use_community_taxon = params[:use_community_taxon] != false

    summary = helpers.inaturalist_find_summary(results, existing_fo_by_uuid, fo_data:, use_community_taxon:) +
              not_found_rows(observation_ids, results)

    render json: { summary: }
  end

  # POST /tasks/field_occurrences/inaturalist_import/import.json
  def import
    observation_ids = params[:observation_ids] || []
    if observation_ids.size > IMPORT_LIMIT
      render json: { error: "Maximum #{IMPORT_LIMIT} observations per submission." }, status: :unprocessable_entity
      return
    end

    results = fetch_inat_results(observation_ids)
    return unless results

    existing_fo_by_uuid = existing_field_occurrences_for(results)
    opts = import_options

    queue_import(results, existing_fo_by_uuid, opts)

    summary = helpers.inaturalist_import_summary(results, existing_fo_by_uuid, **opts) +
              not_found_rows(observation_ids, results)

    render json: { summary: }
  end

  # GET /tasks/field_occurrences/inaturalist_import/check_for_existing.json
  def check_for_existing
    uuids = params[:uuids] || []
    existing_fo_by_uuid = existing_field_occurrences_for_uuids(uuids)
    fo_data = fetch_field_occurrence_data(existing_fo_by_uuid)

    found = existing_fo_by_uuid.map { |uuid, fo_id|
      fo = fo_data[fo_id]
      {
        uuid:,
        field_occurrence_id: fo_id,
        browse_url: helpers.browse_field_occurrence_task_path(field_occurrence_id: fo_id),
        taxon_name: fo[:taxon_name],
        image_count: fo[:image_count],
        sound_count: fo[:sound_count]
      }
    }

    render json: { found: }
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
      .page(params[:page])
      .per(params.fetch(:per_page, 10).to_i.clamp(1, 100))
      .includes(:collecting_event, :identifiers, :depictions, :conveyances, taxon_determinations: { otu: :taxon_name })

    assign_pagination(fos)
    render json: { field_occurrences: fos.map { |fo| helpers.serialize_inat_field_occurrence(fo) } }
  end

  private

  def fetch_inat_results(observation_ids)
    ::Vendor::Nasturtium.by_observation_ids(observation_ids)
  rescue Timeout::Error
    render json: { error: 'The iNaturalist API did not respond in time. Please try again.' }, status: :service_unavailable
    nil
  end

  def existing_field_occurrences_for(results)
    existing_field_occurrences_for_uuids(results.filter_map { |r| r['uuid'] })
  end

  def existing_field_occurrences_for_uuids(uuids)
    FieldOccurrence.by_inat_uuids(uuids, project_id: sessions_current_project_id)
  end

  def not_found_rows(observation_ids, results)
    (observation_ids.to_set - results.map { |r| r['id'].to_s }.to_set)
      .map { |id| { observation_id: id, status: 'not_found' } }
  end

  def import_options
    {
      use_community_taxon: params[:use_community_taxon] != false,
      import_images: params[:import_images] == true,
      import_sounds: params[:import_sounds] == true,
    }
  end

  def queue_import(results, existing_fo_by_uuid, opts)
    new_results = results.reject { |r| existing_fo_by_uuid.key?(r['uuid']) }

    InaturalistImportJob.perform_later(
      results: new_results,
      project_id: sessions_current_project_id,
      user_id: sessions_current_user_id,
      match_otu_by_name: params[:match_otu_by_name] == true,
      **opts
    ) if new_results.any?
  end

  def fetch_field_occurrence_data(existing_fo_by_uuid)
    return {} if existing_fo_by_uuid.empty?

    FieldOccurrence
      .where(id: existing_fo_by_uuid.values)
      .includes(:depictions, :conveyances, taxon_determinations: { otu: :taxon_name })
      .each_with_object({}) do |fo, h|
        h[fo.id] = {
          image_count: fo.depictions.size,
          sound_count: fo.conveyances.size,
          taxon_name: helpers.otu_tag(fo.taxon_determinations.first.otu)
        }
      end
  end

end
