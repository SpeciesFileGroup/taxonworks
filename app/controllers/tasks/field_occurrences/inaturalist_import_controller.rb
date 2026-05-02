require 'nasturtium'

class Tasks::FieldOccurrences::InaturalistImportController < ApplicationController
  include TaskControllerConfiguration

  IMPORT_LIMIT = 50
  FIND_LIMIT   = 200

  def index
  end

  # POST /tasks/field_occurrences/inaturalist_import/submit.json
  def submit
    observation_ids = params[:observation_ids] || []
    find_only = ActiveModel::Type::Boolean.new.cast(params[:find_only])

    limit = find_only ? FIND_LIMIT : IMPORT_LIMIT
    if observation_ids.size > limit
      render json: { error: "Maximum #{limit} observations per submission." }, status: :unprocessable_entity
      return
    end

    begin
      results = ::Vendor::Nasturtium.by_observation_ids(observation_ids)
    rescue Timeout::Error
      render json: { error: 'The iNaturalist API did not respond in time. Please try again.' }, status: :service_unavailable
      return
    end

    candidate_uuids = results.filter_map { |r| r['uuid'] }
    existing_fo_by_uuid = FieldOccurrence.by_inat_uuids(candidate_uuids, project_id: sessions_current_project_id)

    import_images = !find_only && params[:import_images] == true
    import_sounds = !find_only && params[:import_sounds] == true
    use_community_taxon = params[:use_community_taxon] != false

    unless find_only
      new_results = results.reject { |r|
        existing_fo_by_uuid.key?(r['uuid']) || ::Vendor::Nasturtium.taxon_name(r, use_community_taxon:).blank?
      }

      InaturalistImportJob.perform_later(
        results: new_results,
        project_id: sessions_current_project_id,
        user_id: sessions_current_user_id,
        match_otu_by_name: params[:match_otu_by_name] == true,
        use_community_taxon:,
        import_images:,
        import_sounds:
      ) if new_results.any?
    end

    fo_data = find_only ? fetch_fo_data(existing_fo_by_uuid) : {}

    submitted_ids = observation_ids.to_set
    found_ids = results.map { |r| r['id'].to_s }.to_set

    summary = helpers.inaturalist_import_summary(results, existing_fo_by_uuid, import_images:, import_sounds:, use_community_taxon:, find_only:, fo_data:) +
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
      .page(params[:page])
      .per(params.fetch(:per_page, 10).to_i.clamp(1, 100))
      .includes(:collecting_event, :identifiers, :depictions, :conveyances, taxon_determinations: { otu: :taxon_name })

    assign_pagination(fos)
    render json: { field_occurrences: fos.map { |fo| helpers.serialize_inat_field_occurrence(fo) } }
  end

  private

  def fetch_fo_data(existing_fo_by_uuid)
    return {} if existing_fo_by_uuid.empty?

    FieldOccurrence
      .where(id: existing_fo_by_uuid.values)
      .includes(:depictions, :conveyances, taxon_determinations: { otu: :taxon_name })
      .each_with_object({}) do |fo, h|
        h[fo.id] = {
          image_count: fo.depictions.size,
          sound_count: fo.conveyances.size,
          taxon_name: helpers.otu_tag(fo.taxon_determinations.first&.otu)
        }
      end
  end

end
