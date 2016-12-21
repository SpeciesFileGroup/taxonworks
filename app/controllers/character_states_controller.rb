class CharacterStatesController < ApplicationController
  before_action :set_character_state, only: [:show, :edit, :update, :destroy]

  # GET /character_states
  # GET /character_states.json
  def index
    @character_states = CharacterState.all
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_character_state
      @character_state = CharacterState.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def character_state_params
      params.require(:character_state).permit(:name, :label, :descriptor_id, :position, :project_id, :updated_by_id, :created_by_id)
    end
end
