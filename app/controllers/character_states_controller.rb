class CharacterStatesController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_character_state, only: [:show, :edit, :update, :destroy, :annotations]

  # GET /character_states
  # GET /character_states.json
  def index
    @recent_objects = CharacterState.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
    render '/shared/data/all/index'
  end

  # GET /character_states/1
  # GET /character_states/1.json
  def show
  end

  # GET /character_states/new
  def new
    @character_state = CharacterState.new
  end

  # GET /character_states/1/edit
  def edit
  end

  # POST /character_states
  # POST /character_states.json
  def create
    @character_state = CharacterState.new(character_state_params)

    respond_to do |format|
      if @character_state.save
        format.html { redirect_to @character_state, notice: 'Character state was successfully created.' }
        format.json { render :show, status: :created, location: @character_state }
      else
        format.html { render :new }
        format.json { render json: @character_state.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /character_states/1
  # PATCH/PUT /character_states/1.json
  def update
    respond_to do |format|
      if @character_state.update(character_state_params)
        format.html { redirect_to @character_state, notice: 'Character state was successfully updated.' }
        format.json { render :show, status: :ok, location: @character_state }
      else
        format.html { render :edit }
        format.json { render json: @character_state.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /character_states/1
  # DELETE /character_states/1.json
  def destroy
    @character_state.destroy
    respond_to do |format|
      format.html { redirect_to character_states_url, notice: 'Character state was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def list
    @character_states = CharacterState.with_project_id(sessions_current_project_id).page(params[:page])
  end

  # TODO: remove
  # GET /character_states/annotations.json
  def annotations
    @object = @character_state
    render '/shared/data/all/annotations'
  end

  private
  def set_character_state
    @character_state = CharacterState.find(params[:id])
  end

  def character_state_params
    params.require(:character_state).permit(:name, :key_name, :description_name, :label, :descriptor_id, :position)
  end

end
