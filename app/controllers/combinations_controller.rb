class CombinationsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :require_sign_in_and_project_selection
  before_action :set_combination, only: [:update, :edit, :update, :destroy, :show]

  # GET /combinations.json
  def index
    @recent_objects = Combination.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(5)
  end

  # GET /combinations/123.json
  def show
  end

  # GET /combinations/new
  def new
    redirect_to new_combination_task_path(params.permit(:id))
  end

  # GET /combinations/1/edit
  def edit
    redirect_to new_combination_task_path(params.require(:id))
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
        format.html { redirect_to url_for(@combination.metamorphosize), notice: 'Combination was successfully updated.' }
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
  def set_combination
    @combination = Combination.with_project_id(sessions_current_project_id).find(params.require(:id))
    @recent_object = @combination 
  end

  def combination_params
    p = ::Combination::APPLICABLE_RANKS.inject(Hash.new){|hsh, r| hsh.merge "#{r}_taxon_name_relationship_attributes".to_sym => [:id, :_destroy] }
    params.require(:combination).permit(
      :verbatim_name, :source_id, 
      *Combination::APPLICABLE_RANKS.collect{ |r| "#{r}_id".to_sym},
      p,
      origin_citation_attributes: [:id, :_destroy, :source_id, :pages],
    )
  end

end
