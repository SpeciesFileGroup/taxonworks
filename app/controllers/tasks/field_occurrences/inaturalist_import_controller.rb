 require 'nasturtium'

class Tasks::FieldOccurrences::InaturalistImportController < ApplicationController
  include TaskControllerConfiguration

  # GET /tasks/field_occurrences/inaturalist_import
  def index
    @recent_field_occurrences = recent_field_occurrences
  end

  # POST /tasks/field_occurrences/inaturalist_import/submit
  def submit
    raw_input = params[:observation_ids]
    match_otu_by_name = params[:match_otu_by_name] == '1'
    use_community_taxon = params[:use_community_taxon] != '0'
    import_images = params[:import_images] == '1'

    observation_ids = ::Vendor::Nasturtium.parse_observation_ids(raw_input)

    if observation_ids.empty?
      flash[:alert] = 'No valid iNaturalist observation IDs found in the input.'
      redirect_to inaturalist_import_task_path and return
    end

    InaturalistImportJob.perform_later(
      observation_ids:,
      project_id: sessions_current_project_id,
      user_id: sessions_current_user_id,
      match_otu_by_name:,
      use_community_taxon:,
      import_images:
    )

    flash[:notice] = "Queued import of #{observation_ids.size} observation(s). Refresh the page to see results."
    redirect_to inaturalist_import_task_path
  end

  private

  def recent_field_occurrences
    FieldOccurrence
      .joins(:identifiers)
      .where(
        project_id: sessions_current_project_id,
        identifiers: { type: 'Identifier::Global::Uuid::InaturalistObservation' }
      )
      .order(created_at: :desc)
      .limit(10)
      .includes(:collecting_event, taxon_determinations: :otu)
  end

end
