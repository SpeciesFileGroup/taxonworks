class BiologicalAssociationsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_biological_association, only: [:show, :edit, :update, :destroy, :api_show, :api_globi, :api_resource_relationship]
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
    redirect_to edit_biological_associations_graph_task_path
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
        send_data Export::Csv.generate_csv(
          @biological_associations,
          exclude_columns: %w{updated_by_id created_by_id project_id},
        ), type: 'text',
       filename: "biological_associations_#{DateTime.now}.tsv"
      }

      format.globi {
        if q.count < 1001
          send_data Export::Csv::Globi.csv(q.all),
          type: 'text',
            filename: "biological_associations_globi_#{DateTime.now}.tsv"
        else
          render json: { msg: 'At present this format is only allowed for 100 or less records.' }, status: :unprocessable_entity
        end
      }
    end
  end

  # POST /biological_associations/batch_update.json?biological_association_query=<>&biological_association={}
  def batch_update
    if r = BiologicalAssociation.batch_update(
        {
          preview: params[:preview],
          biological_association: biological_association_params.merge(by: sessions_current_user_id) ,
          biological_association_query: params[:biological_association_query]
      }
    )
      render json: r.to_json, status: :ok
    else
      render json: {}, status: :unprocessable_entity
    end
  end

  # POST /biological_associations/batch_rotate.json?biological_association_query=<>&biological_association={}
  def batch_rotate
    if r = BiologicalAssociation.batch_rotate(
        params.merge(by: sessions_current_user_id)
    )
      render json: r.to_json, status: :ok
    else
      render json: {}, status: :unprocessable_entity
    end
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
      origin_citation_attributes: [:id, :_destroy, :source_id, :pages],
      citations_attributes: [:id, :is_original, :_destroy, :source_id, :pages, :citation_object_id, :citation_object_type],
    )
  end
end
