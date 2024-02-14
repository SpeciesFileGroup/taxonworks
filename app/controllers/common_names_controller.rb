class CommonNamesController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration
  before_action :set_common_name, only: [:show, :edit, :update, :destroy, :api_show ]

  after_action -> { set_pagination_headers(:common_names) }, only: [:api_index], if: :json_request?

  # GET /common_names
  # GET /common_names.json
  def index
  end

  def index
    respond_to do |format|
      format.html do
        @recent_objects = CommonName.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      end
      format.json {
        @common_names = Queries::CommonName::Filter.new(params).all
          .page(params[:page])
          .per(params[:per])
      }
    end
  end

  # GET /common_names/1
  # GET /common_names/1.json
  def show
  end

  # GET /common_names/new
  def new
    @common_name = CommonName.new
  end

  # GET /common_names/1/edit
  def edit
  end

  def list
    @common_names = CommonName.with_project_id(sessions_current_project_id).page(params[:page]) #.per(10)
  end

  # POST /common_names
  # POST /common_names.json
  def create
    @common_name = CommonName.new(common_name_params)

    respond_to do |format|
      if @common_name.save
        format.html { redirect_to @common_name, notice: 'Common name was successfully created.' }
        format.json { render :show, status: :created, location: @common_name }
      else
        format.html { render :new }
        format.json { render json: @common_name.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /common_names/1
  # PATCH/PUT /common_names/1.json
  def update
    respond_to do |format|
      if @common_name.update(common_name_params)
        format.html { redirect_to @common_name, notice: 'Common name was successfully updated.' }
        format.json { render :show, status: :ok, location: @common_name }
      else
        format.html { render :edit }
        format.json { render json: @common_name.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /common_names/1
  # DELETE /common_names/1.json
  def destroy
    @common_name.destroy
    respond_to do |format|
      format.html { redirect_to common_names_url, notice: 'Common name was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /api/v1/common_names.csv
  # GET /api/v1/common_names
  def api_index
    q = ::Queries::CommonName::Filter.new(params.merge!(api: true)).all
      .where(project_id: sessions_current_project_id)
      .order('common_names.id')
      .page(params[:page])
      .per(params[:per])

    respond_to do |format|
      format.json {
        @common_names = q.page(params[:page]).per(params[:per])
        render '/common_names/api/v1/index'
      }
      format.csv {
        @common_names = q
        send_data Export::CSV.generate_csv(
          @common_names,
          exclude_columns: %w{updated_by_id created_by_id project_id},
        ), type: 'text', filename: "common_names_#{DateTime.now}.tsv"
      }
    end
  end

  # GET /api/v1/common_names/:id
  def api_show
    render '/common_names/api/v1/show'
  end

  private

  def set_common_name
    @common_name = CommonName.with_project_id(sessions_current_project_id).find(params[:id])
  end

  def common_name_params
    params.require(:common_name).permit(:name, :geographic_area_id, :otu_id, :language_id, :start_year, :end_year)
  end
end
