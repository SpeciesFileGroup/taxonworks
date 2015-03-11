class CombinationsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :require_sign_in_and_project_selection
  before_action :set_content, only: [:update, :edit, :update, :destroy]

  # GET /combinations/new
  def new
    if params[:taxon_name_id]
      @protonym = Protonym.find(params[:taxon_name_id])
      @combination = Combination.new(@protonym.rank => @protonym)
    else
      @combination = Combination.new
    end
  end

  # GET /combinations/1/edit
  def edit
  end

  # POST /combinations.json
  def create

    @combination = Combination.new(combination_params)
    respond_to do |format|
      if @combination.save
        format.html { redirect_to taxon_names_path, notice: 'Combination was successfully created.' }
        format.json { render :show, status: :created, location: @combination.metamorphosize }
      else
        format.html { render :new }
        format.json { render json: @combination.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /combinations/1
  # PATCH/PUT /combinations/1.json
  def update
    respond_to do |format|
      if @combination.update(combination_params)
        format.html { redirect_to @combination.metamorphosize, notice: 'Combination was successfully updated.' }
        format.json { render :show, status: :ok, location: @combination.metamorphosize }
      else
        format.html { render :edit }
        format.json { render json: @combination.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /combinations/1
  # DELETE /combinations/1.json
  def destroy
    @combination.destroy
    respond_to do |format|
      format.html { redirect_to taxon_names_url }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_content
    @combination = Combination.with_project_id($project_id).find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def combination_params
    params.require(:combination).permit(:source_id, *Combination::APPLICABLE_RANKS.collect{|r| "#{r}_id".to_sym})
  end
end
