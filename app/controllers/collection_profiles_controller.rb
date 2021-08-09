class CollectionProfilesController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_collection_profile, only: [:show, :edit, :update, :destroy]

  # GET /collection_profiles
  # GET /collection_profiles.json
  def index
    @recent_objects = CollectionProfile.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
    render '/shared/data/all/index'
  end

  # GET /collection_profiles/1
  # GET /collection_profiles/1.json
  def show
  end

  # GET /collection_profiles/new
  def new
    @collection_profile = CollectionProfile.new(collection_type: :dry)
  end

  # GET /collection_profiles/1/edit
  def edit
  end

  def swap_form_attribute_types
    render partial: 'collection_profile_collection_type_attributes_form', locals: { collection_profile: CollectionProfile.new(params.permit(:collection_type)) }
  end

  # POST /collection_profiles
  # POST /collection_profiles.json
  def create
    @collection_profile = CollectionProfile.new(collection_profile_params)

    respond_to do |format|
      if @collection_profile.save
        format.html { redirect_to @collection_profile, notice: 'Collection profile was successfully created.' }
        format.json { render :show, status: :created, location: @collection_profile }
      else
        format.html { render :new }
        format.json { render json: @collection_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /collection_profiles/1
  # PATCH/PUT /collection_profiles/1.json
  def update
    respond_to do |format|
      if collection_profile_params['force_update'] == '0'
        flash['notice'] = 'Collection profile are not updatable unless forced, consider cloning this record or click force.'
        render :edit and return
      end

      if @collection_profile.update(collection_profile_params)
        format.html { redirect_to @collection_profile, notice: 'Collection profile was successfully updated.' }
        format.json { render :show, status: :ok, location: @collection_profile }
      else
        format.html { render :edit }
        format.json { render json: @collection_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /collection_profiles/1
  # DELETE /collection_profiles/1.json
  def destroy
    @collection_profile.destroy
    respond_to do |format|
      format.html { redirect_to collection_profiles_url }
      format.json { head :no_content }
    end
  end

  def search
    if params[:id].blank?
      redirect_to collection_profiles_path, alert: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to collection_profile_path(params[:id])
    end
  end

  def autocomplete
    @collection_profiles = CollectionProfile.find_for_autocomplete(params.merge(project_id: sessions_current_project_id)).include(:taxon_names)
    data = @collection_profile.collect do |t|
      {id: t.id,
       label: ApplicationController.helpers.collection_profile_tag(t),
       response_values: {
           params[:method] => t.id
       },
       label_html: ApplicationController.helpers.collection_profile_tag(t)
      }
    end

    render json: data
  end

  def list
    @collection_profiles = CollectionProfile.order(:id).page(params[:page]) #.per(10) #.per(3)
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_collection_profile
    @collection_profile = CollectionProfile.with_project_id(sessions_current_project_id).find(params[:id])
    @recent_object = @collection_profile
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def collection_profile_params
    params.require(:collection_profile).permit(:container_id, :otu_id, :conservation_status, :processing_state,
                                               :container_condition, :condition_of_labels, :identification_level,
                                               :arrangement_level, :data_quality, :computerization_level,
                                               :number_of_collection_objects, :number_of_containers, :collection_type, :force_update
    )
  end
end
