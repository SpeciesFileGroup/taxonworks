class CollectionObjectObservationsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_collection_object_observation, only: [:show, :edit, :update, :destroy]

  # GET /collection_object_observations
  # GET /collection_object_observations.json
  def index
    @recent_objects = CollectionObjectObservation.recent_from_project_id(sessions_current_project_id)
      .order(updated_at: :desc).limit(10)
    render '/shared/data/all/index'
  end

  # GET /collection_object_observations/1
  # GET /collection_object_observations/1.json
  def show
  end

  # GET /collection_object_observations/new
  def new
    @collection_object_observation = CollectionObjectObservation.new
  end

  # GET /collection_object_observations/1/edit
  def edit
  end

  # POST /collection_object_observations
  # POST /collection_object_observations.json
  def create
    @collection_object_observation = CollectionObjectObservation.new(collection_object_observation_params)

    respond_to do |format|
      if @collection_object_observation.save
        format.html { redirect_to @collection_object_observation,
                                  notice: 'Collection object observation was successfully created.' }
        format.json { render :show, status: :created, location: @collection_object_observation }
      else
        format.html { render :new }
        format.json { render json: @collection_object_observation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /collection_object_observations/1
  # PATCH/PUT /collection_object_observations/1.json
  def update
    respond_to do |format|
      if @collection_object_observation.update(collection_object_observation_params)
        format.html { redirect_to @collection_object_observation,
                                  notice: 'Collection object observation was successfully updated.' }
        format.json { render :show, status: :ok, location: @collection_object_observation }
      else
        format.html { render :edit }
        format.json { render json: @collection_object_observation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /collection_object_observations/1
  # DELETE /collection_object_observations/1.json
  def destroy
    @collection_object_observation.destroy!
    respond_to do |format|
      format.html { redirect_to collection_object_observations_url,
                    notice: 'Collection object observation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def list
    @collection_object_observations = CollectionObjectObservation.with_project_id(sessions_current_project_id)
                                        .order(:id).page(params[:page]) #.per(10)
  end

  def autocomplete
    @collection_object_observations = CollectionObjectObservation.find_for_autocomplete(params.merge(project_id: sessions_current_project_id))

    data = @collection_object_observations.collect do |t|
      {id: t.id,
       label: t.data,
       response_values: {
         params[:method] => t.id
       },
       label_html: t.data
      }
    end
    render json: data
  end

  def search
    if params[:id].blank?
      redirect_to collection_object_observations_path,
                  alert: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to collection_object_observation_path(params[:id])
    end
  end

  # GET /collection_object_observations/download
  def download
    send_data(Export::Download.generate_csv(CollectionObjectObservation.where(project_id: sessions_current_project_id)),
              type: 'text',
              filename: "collection_object_observations_#{DateTime.now}.csv")
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_collection_object_observation
      @collection_object_observation = CollectionObjectObservation.where(project_id: sessions_current_project_id).find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def collection_object_observation_params
      params.require(:collection_object_observation).permit(:data)
    end
end
