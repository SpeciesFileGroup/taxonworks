class SoundsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration
  
  before_action :set_sound, only: %i[ show edit update destroy ]

  after_action -> { set_pagination_headers(:sounds) }, only: [:index, :api_index], if: :json_request?

  # GET /sounds or /sounds.json
  def index
    respond_to do |format|
      format.html do
        @recent_objects = Sound.where(project_id: sessions_current_project_id).order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      end
      format.json {
        @sounds = Queries::Sound::Filter.new(params).all
          .where(project_id: sessions_current_project_id)
          .page(params[:page]).per(params[:per])
      }
    end
  end

  # GET /sounds/1 or /sounds/1.json
  def show
  end

  # GET /sounds/new
  def new
    @sound = Sound.new
  end

  # GET /sounds/1/edit
  def edit
  end

  # POST /sounds or /sounds.json
  def create
    @sound = Sound.new(sound_params)

    respond_to do |format|
      if @sound.save
        format.html { redirect_to @sound, notice: 'Sound was successfully created.' }
        format.json { render :show, status: :created, location: @sound }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @sound.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sounds/1 or /sounds/1.json
  def update
    respond_to do |format|
      if @sound.update(sound_params)
        format.html { redirect_to @sound, notice: 'Sound was successfully updated.' }
        format.json { render :show, status: :ok, location: @sound }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @sound.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sounds/1 or /sounds/1.json
  def destroy
    @sound.destroy!

    respond_to do |format|
      format.html { redirect_to sounds_path, status: :see_other, notice: 'Sound was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def select_options
    @sounds = Sound.select_optimized(
      sessions_current_user_id, 
      sessions_current_project_id,
     params.require(:target))
  end


  def list
    @sounds = Sound.where(project_id: sessions_current_project_id).page(params[:page]).per(params[:per])
  end

  def autocomplete
    @sounds = Sound.where(project_id: sessions_current_project_id)
      .where('name ilike ?', "%#{ params.require(:term)}%")
      .order(:name)
      .limit(20)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
  def set_sound
    @sound = Sound.find(params[:id])
  end

    # Only allow a list of trusted parameters through.
  def sound_params
    params.require(:sound).permit(:name, :sound_file)
  end
end
