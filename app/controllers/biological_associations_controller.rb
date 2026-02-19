class BiologicalAssociationsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_biological_association, only: [:show, :edit, :update,
    :destroy, :api_show, :api_globi, :api_resource_relationship, :navigation]
  after_action -> { set_pagination_headers(:biological_associations) },
    only: [:index, :api_index, :api_index_simple, :api_index_basic], if: :json_request?

  # GET /biological_associations
  # GET /biological_associations.json
  def index
    respond_to do |format|
      format.html {
        @recent_objects = BiologicalAssociation.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      }
      format.json {
        @biological_associations = Queries::BiologicalAssociation::Filter.new(params)
          .all
          .where(project_id: sessions_current_project_id)
          .page(params[:page])
          .per(params[:per])
      }
    end
  end

  # GET /biological_associations/1
  # GET /biological_associations/1.json
  def show
  end

  # GET /biological_associations/new
  def new
    redirect_to new_biological_association_task_path
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
    if create_with_anatomical_parts?
      service = ::BiologicalAssociations::CreateWithAnatomicalParts.new(biological_association_params)
      success = service.call
      @biological_association = service.biological_association
    else
      @biological_association = BiologicalAssociation.new(biological_association_params)
      success = @biological_association.save
    end

    respond_to do |format|
      if success
        format.html { redirect_to @biological_association, notice: 'Biological association was successfully created.' }
        format.json { render :show, status: :created, location: @biological_association }
      else
        format.html { render :new }
        errors = @biological_association&.errors&.presence || { errors: service&.errors || [] }
        format.json { render json: errors, status: :unprocessable_content }
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
        format.json { render json: @biological_association.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /biological_associations/1
  # DELETE /biological_associations/1.json
  def destroy
    @biological_association.destroy
    respond_to do |format|
      if @biological_association.destroyed?
        format.html { redirect_to biological_associations_url, notice: 'Biological association was successfully destroyed.' }
        format.json { head :no_content }
      else
        format.html { destroy_redirect @biological_association, notice: 'Biological association was not destroyed: ' + @biological_association.errors.full_messages.join('; ') }
        format.json { render json: @biological_association.errors, status: :unprocessable_content }
      end
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

  def api_globi
    render json:  @biological_association.globi_extension_json, status: :ok
  end

  def api_resource_relationship
    render json:  @biological_association.globi_extension_json, status: :ok
  end

  def api_index
    q = ::Queries::BiologicalAssociation::Filter.new(params.merge!(api: true)).all
      .where(project_id: sessions_current_project_id)
      .order('biological_associations.id')

    respond_to do |format|
      format.json {
        @biological_associations = q.page(params[:page]).per(params[:per])
        render '/biological_associations/api/v1/index'
      }

      format.csv {
        @biological_associations = q
        send_data Export::CSV.generate_csv(
          @biological_associations,
          exclude_columns: %w{updated_by_id created_by_id project_id},
        ), type: 'text',
       filename: "biological_associations_#{DateTime.now}.tsv"
      }

      format.globi {
        if q.page(params[:page]).per(params[:per]).count < 1001
          send_data Export::CSV::Globi.csv(q.page(params[:page]).per(params[:per])),
            type: 'text',
            filename: "biological_associations_globi_#{DateTime.now}.tsv"
        else
          render json: { msg: 'At present this format is only allowed for 1000 or less records.' }, status: :unprocessable_content
        end
      }
    end
  end

  def api_index_simple
    @biological_associations = ::Queries::BiologicalAssociation::Filter.new(params.merge!(api: true))
      .all
      .where(project_id: sessions_current_project_id)
      .order('biological_associations.id')
      .page(params[:page])
      .per(params[:per])

    respond_to do |format|
      format.json  { render '/biological_associations/api/v1/simple' and return }
      format.csv {
        send_data Export::CSV::BiologicalAssociations::Simple.csv(@biological_associations),
        type: 'text',
        filename: "biological_associations_simple_#{DateTime.now}.tsv"
      }
    end
  end

  def api_index_extended
    @biological_associations = ::Queries::BiologicalAssociation::Filter.new(params.merge!(api: true))
      .all
      .where(project_id: sessions_current_project_id)
      .order('biological_associations.id')
      .page(params[:page])
      .per(params[:per])

    respond_to do |format|
      format.json  { render '/biological_associations/api/v1/extended' and return }
      format.csv {
        send_data Export::CSV::BiologicalAssociations::Extended.csv(@biological_associations),
        type: 'text',
        filename: "biological_associations_extended_#{DateTime.now}.tsv"
      }
    end
  end

  def api_index_basic
    @biological_associations = ::Queries::BiologicalAssociation::Filter.new(params.merge!(api: true))
      .all
      .where(project_id: sessions_current_project_id)
      .select('biological_associations.id')
      .includes(:biological_association_index)
      .order('biological_associations.id')
      .page(params[:page])
      .per(params[:per])

    render '/biological_associations/api/v1/basic'
  end

  # PATCH /biological_associations/batch_update.json?biological_association_query=<>&biological_association={}
  def batch_update
    if r = BiologicalAssociation.batch_update(
        preview: params[:preview],
        biological_association: biological_association_params.merge(by: sessions_current_user_id),
        biological_association_query: params[:biological_association_query],
        user_id: sessions_current_user_id,
        project_id: sessions_current_project_id)
      render json: r.to_json, status: :ok
    else
      render json: {}, status: :unprocessable_content
    end
  end

  def autocomplete
    @biological_associations =
      ::Queries::BiologicalAssociation::Autocomplete.new(
        params.require(:term),
        project_id: sessions_current_project_id,
      ).autocomplete
  end

  def search
    if params[:id].blank?
      redirect_to(biological_association_path,
                  alert: 'You must select an item from the list with a click or tab press before clicking show.')
    else
      redirect_to biological_association_path(params[:id])
    end
  end

  # GET /biological_associations/1/navigation.json
  def navigation
  end

  def select_options
    @biological_associations = BiologicalAssociation.select_optimized(sessions_current_user_id, sessions_current_project_id, params.require(:target))
  end

  def subject_object_types
    hash = BIOLOGICALLY_RELATABLE_TYPES.reduce({}) do |h, val|
      h[val] = val.tableize
       h
    end
    render json: hash
  end

  # GET /biological_associations/origin_subject_index.json?origin_object_id=1&origin_object_type=Otu
  # Returns BAs whose subject is an AnatomicalPart originated from the base object.
  def origin_subject_index
    object_id = params.require(:origin_object_id).to_i
    object_type = params.require(:origin_object_type).to_s

    @biological_associations = BiologicalAssociation
      .joins("INNER JOIN origin_relationships ap_origin_relationships ON ap_origin_relationships.new_object_id = biological_associations.biological_association_subject_id")
      .where(project_id: sessions_current_project_id)
      .where(biological_association_subject_type: 'AnatomicalPart')
      .where("ap_origin_relationships.new_object_type = 'AnatomicalPart'")
      .where(
        'ap_origin_relationships.old_object_id = ? AND ap_origin_relationships.old_object_type = ?',
        object_id,
        object_type
      )
      .order('biological_associations.updated_at DESC')

    render '/biological_associations/origin_subject_index'
  end

  private

  def set_biological_association
    @biological_association = BiologicalAssociation.where(project_id: sessions_current_project_id).find(params[:id])
  end

  def biological_association_params
    params.require(:biological_association).permit(
      :biological_relationship_id, :biological_association_subject_id, :biological_association_subject_type,
      :biological_association_object_id, :biological_association_object_type,
      :subject_global_id,
      :object_global_id,
      :rotate,
      subject_anatomical_part_attributes: [:name, :uri, :uri_label, :is_material, :preparation_type_id],
      object_anatomical_part_attributes: [:name, :uri, :uri_label, :is_material, :preparation_type_id],
      subject_taxon_determination_attributes: [:otu_id],
      object_taxon_determination_attributes: [:otu_id],
      origin_citation_attributes: [:id, :_destroy, :source_id, :pages],
      citations_attributes: [:id, :is_original, :_destroy, :source_id, :pages, :citation_object_id, :citation_object_type],
    )
  end

  def create_with_anatomical_parts?
    p = biological_association_params
    p[:subject_anatomical_part_attributes].present? ||
      p[:object_anatomical_part_attributes].present? ||
      p[:subject_taxon_determination_attributes].present? ||
      p[:object_taxon_determination_attributes].present?
  end
end
