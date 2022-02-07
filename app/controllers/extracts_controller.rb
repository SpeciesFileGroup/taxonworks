class ExtractsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_extract, only: [:show, :edit, :update, :destroy]

  # GET /extracts
  # GET /extracts.json
  def index
      respond_to do |format|
      format.html do
        @recent_objects = Extract.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      end
      format.json {
        @extracts = Queries::Extract::Filter.
        new(filter_params).all.where(project_id: sessions_current_project_id).
        page(params[:page]).per(params[:per] || 500)
      }
      end
  end

  # GET /extracts/1
  # GET /extracts/1.json
  def show
  end

  # GET /extracts/new
  def new
    @extract = Extract.new
  end

  # GET /extracts/1/edit
  def edit
  end

  def list
    @extracts = Extract.with_project_id(sessions_current_project_id).page(params[:page])
  end

  # POST /extracts
  # POST /extracts.json
  def create
    @extract = Extract.new(extract_params)

    respond_to do |format|
      if @extract.save
        format.html { redirect_to @extract, notice: 'Extract was successfully created.' }
        format.json { render :show, status: :created, location: @extract }
      else
        format.html { render :new }
        format.json { render json: @extract.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /extracts/1
  # PATCH/PUT /extracts/1.json
  def update
    respond_to do |format|
      if @extract.update(extract_params)
        format.html { redirect_to @extract, notice: 'Extract was successfully updated.' }
        format.json { render :show, status: :ok, location: @extract }
      else
        format.html { render :edit }
        format.json { render json: @extract.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /extracts/1
  # DELETE /extracts/1.json
  def destroy
    @extract.destroy
    respond_to do |format|
      format.html { redirect_to extracts_url, notice: 'Extract was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def search
    if params[:id].blank?
      redirect_to extracts_path, alert: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to extract_path(params[:id])
    end
  end

  # GET /extracts/select_options
  def select_options
    @extracts = Extract.select_optimized(sessions_current_user_id, sessions_current_project_id)
  end

  private
    def set_extract
      @extract = Extract.where(project_id: sessions_current_project_id).find(params[:id])
    end

    def filter_params
      params.permit(
        :id,
        :user_date_end,
        :user_date_start,
        :user_id,
        :identifier,
        :identifier_end,
        :identifier_exact,
        :identifier_start,
        :identifier_type,
        :recent,
        :otu_id,
        :collection_object_id,
        :repository_id,
        :extract_start_date_range,
        :extract_end_date_range,
        :ancestor_id,
        :sequences,
        :extract_origin,
        collection_object_id: [],
        otu_id: [],
        keyword_id_and: [],
        keyword_id_or: [],
        repository_id: [],
      )
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def extract_params
      params.require(:extract).permit(
        :repository_id,
        :verbatim_anatomical_origin,
        :year_made,
        :month_made,
        :day_made,

        roles_attributes: [
          :id,
          :_destroy,
          :type,
          :person_id,
          :position,
          person_attributes: [
            :last_name,
            :first_name,
            :suffix, :prefix
          ]
        ],

        identifiers_attributes: [
          :id,
          :namespace_id,
          :identifier,
          :type,
          :_destroy
        ],

        data_attributes_attributes: [
          :id,
          :_destroy,
          :controlled_vocabulary_term_id,
          :type,
          :attribute_subject_id,
          :attribute_subject_type,
          :value
        ],

        protocol_relationships_attributes: [
          :id,
          :_destroy,
          :protocol_id
        ],

        origin_relationships_attributes: [
          :id,
          :_destroy,
          :old_object_id,
          :old_object_type
        ]
      )
    end
end
