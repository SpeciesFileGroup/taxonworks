class BiologicalAssociationsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_biological_association, only: [:show, :edit, :update, :destroy, :api_show]
  after_action -> { set_pagination_headers(:biological_associations) }, only: [:index], if: :json_request?

  # GET /biological_associations
  # GET /biological_associations.json
  def index
    respond_to do |format|
      format.html {
        @recent_objects = BiologicalAssociation.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      }
      format.json {
        @biological_associations = Queries::BiologicalAssociation::Filter.new(filter_params)
          .all
          .where(project_id: sessions_current_project_id)
          .page(params[:page]).per(params[:per])
      }
    end
  end

  # GET /biological_associations/1
  # GET /biological_associations/1.json
  def show
  end

  # GET /biological_associations/new
  def new
    @biological_association = BiologicalAssociation.new
  end

  # GET /biological_associations/1/edit
  def edit
  end

  def list
    @biological_associations = BiologicalAssociation.with_project_id(sessions_current_project_id).order(:id).page(params[:page]) #.per(10)
  end

  # POST /biological_associations
  # POST /biological_associations.json
  def create
    @biological_association = BiologicalAssociation.new(biological_association_params)
    respond_to do |format|
      if @biological_association.save
        format.html { redirect_to @biological_association, notice: 'Biological association was successfully created.' }
        format.json { render :show, status: :created, location: @biological_association }
      else
        format.html { render :new }
        format.json { render json: @biological_association.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /biological_associations/1
  # PATCH/PUT /biological_associations/1.json
  def update
    respond_to do |format|
      if @biological_association.update(biological_association_params)
        format.html { redirect_to @biological_association, notice: 'Biological association was successfully updated.' }
        format.json { render :show, status: :ok, location: @biological_association }
      else
        format.html { render :edit }
        format.json { render json: @biological_association.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /biological_associations/1
  # DELETE /biological_associations/1.json
  def destroy
    @biological_association.destroy
    respond_to do |format|
      format.html { redirect_to biological_associations_url, notice: 'Biological association was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def search
    if params[:id].blank?
      redirect_to biological_associations_path, alert: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to biological_association_path(params[:id])
    end
  end


  def api_show
    render '/biological_associations/api/v1/show'
  end

  def api_index
    @biological_associations = Queries::BiologicalAssociation::Filter.new(api_params).all
      .where(project_id: sessions_current_project_id)
      .order('biological_associations.id')
      .page(params[:page])
      .per(params[:per])
    render '/biological_associations/api/v1/index'
  end

  private

  def filter_params
    params.permit(
      ::Queries::BiologicalAssociation::Filter::PARAMS,
      :identifier,
      :identifier_end,
      :identifier_exact,
      :identifier_start,
      :identifiers,
      :match_identifiers,
      :match_identifiers_delimiter,
      :match_identifiers_type,
      :note_exact, # Notes concern
      :note_text,
      :notes,
      keyword_id_and: [],
      keyword_id_or: [],

      any_global_id: [],
      biological_association_id: [],
      biological_associations_graph_id: [],
      biological_relationship_id: [],
      collecting_event_id: [],
      collection_object_id: [],
      object_biological_property_id: [],
      object_global_id: [],
      otu_id: [],
      subject_biological_property_id: [],
      subject_global_id: [],
      taxon_name_id: [],
    )

    params
  end

  def api_params
    params.permit(
      ::Queries::BiologicalAssocation::PARAMS,

      :identifier,
      :identifier_end,
      :identifier_exact,
      :identifier_start,
      :identifiers,
      :match_identifiers,
      :match_identifiers_delimiter,
      :match_identifiers_type,

      :note_exact, # Notes concern
      :note_text,
      :notes,

      keyword_id_and: [],
      keyword_id_or: [],

      any_global_id: [],
      biological_association_id: [],
      biological_associations_graph_id: [],
      biological_relationship_id: [],
      collecting_event_id: [],
      collection_object_id: [],
      object_biological_property_id: [],
      object_global_id: [],
      otu_id: [],
      subject_biological_property_id: [],
      subject_global_id: [],
      taxon_name_id: [],
    )

    # Shallow resource hack
    if !params[:collection_object_id].blank? && c = CollectionObject.where(project_id: sessions_current_project_id).find(params[:collection_object_id])
      params[:any_global_id] = c.to_global_id.to_s
    end
    params
  end

  def set_biological_association
    @biological_association = BiologicalAssociation.where(project_id: sessions_current_project_id).find(params[:id])
  end

  def biological_association_params
    params.require(:biological_association).permit(
      :biological_relationship_id, :biological_association_subject_id, :biological_association_subject_type,
      :biological_association_object_id, :biological_association_object_type,
      :subject_global_id,
      :object_global_id,
      origin_citation_attributes: [:id, :_destroy, :source_id, :pages],
      citations_attributes: [:id, :is_original, :_destroy, :source_id, :pages, :citation_object_id, :citation_object_type],
    )
  end
end
