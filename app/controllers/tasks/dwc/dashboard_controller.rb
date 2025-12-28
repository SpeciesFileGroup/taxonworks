class Tasks::Dwc::DashboardController < ApplicationController
  include TaskControllerConfiguration

  # DWC_TASK
  def index
  end

  # /tasks/dwc/dashboard/generate_download.json
  # !! Run rails jobs:work in the terminal to complete builds
  def generate_download
    q = ::Queries::DwcOccurrence::Filter.new(params)

    biological_associations_query = nil
    if params[:biological_associations_extension]
      # TODO: this should include field occurrences as well, but they won't
      # actually be exported until core (q) includes field occurrences.
      biological_associations_query = {
        core_params: q.params,
        collection_objects_query: ::Queries::BiologicalAssociation::Filter.new(
            collection_object_query: ::Queries::CollectionObject::Filter.new(
              dwc_occurrence_query: q.params
            ).params
          ).all.to_sql
      }
    end

    media_query = nil
    if params[:media_extension]
      if sessions_current_project.api_access_token.nil?
        render json: { note: 'A project API Acess Token is required for exporting media - contact your project administrator for details' }, status: :unprocessable_content
        return
      end
      media_query = {
        collection_objects: ::Queries::CollectionObject::Filter.new(
          dwc_occurrence_query: q.params
        ).all.to_sql,

        field_occurrences: ::Queries::FieldOccurrence::Filter.new(
          dwc_occurrence_query: q.params
        ).all.to_sql
      }
    end

    @download = ::Export::Dwca.download_async(
      q.all, request.url,
      predicate_extensions: predicate_extension_params,
      taxonworks_extensions: taxonworks_extension_params,
      extension_scopes: {
        biological_associations: biological_associations_query,
        media: media_query
      },
      project_id: sessions_current_project_id
    )
    render '/downloads/show'
  end

  # TODO: throttle to 5k.
  def create_index
    q = ::Queries::CollectionObject::Filter.new(params)
    q.project_id = nil

    if q.all(true)
      q.project_id = sessions_current_project_id
      metadata = ::Export::Dwca.build_index_async(CollectionObject, q.all)
      render json: metadata, status: :ok
    else
      render json: {}, status: :unprocessable_content
    end
  end

  def index_versions
    render json: ::Export::Dwca::INDEX_VERSION, status: :ok
  end

  def taxonworks_extension_methods
    render json: ::CollectionObject::DwcExtensions::TaxonworksExtensions::EXTENSION_FIELDS, status: :ok
  end

  def checklist_extensions
    extensions = [
      { value: Export::Dwca::ChecklistData::DISTRIBUTION_EXTENSION, label: 'Distribution' },
      { value: Export::Dwca::ChecklistData::REFERENCES_EXTENSION, label: 'References' },
      { value: Export::Dwca::ChecklistData::TYPES_AND_SPECIMEN_EXTENSION, label: 'Types and Specimen' },
      { value: Export::Dwca::ChecklistData::VERNACULAR_NAME_EXTENSION, label: 'Vernacular Name' }
    ]
    render json: extensions, status: :ok
  end

  def generate_checklist_download
    core_otu_scope_params = params[:otu_query]&.to_unsafe_h || {}
    extensions = (params[:extensions] || []).map(&:to_sym)
    accepted_name_mode = params[:accepted_name_mode] || 'exclude_unaccepted_names'

    @download = ::Export::Dwca.checklist_download_async(
      core_otu_scope_params,
      request.url,
      extensions:,
      accepted_name_mode:,
      project_id: sessions_current_project_id
    )
    render '/downloads/show'
  end

  private

  def predicate_extension_params
    a = params.permit(collecting_event_predicate_id: [], collection_object_predicate_id: []).to_h.symbolize_keys
  end

  def taxonworks_extension_params
    a = params.permit(taxonworks_extension_methods: []).dig(:taxonworks_extension_methods)
    a ? a.map(&:to_sym) : {}
  end

end
