class AssertedDistributionsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_asserted_distribution, only: [:show, :edit, :update, :destroy]

  # GET /asserted_distributions
  # GET /asserted_distributions.json
  def index
    @recent_objects = AssertedDistribution.recent_from_project_id($project_id).order(updated_at: :desc).limit(10)
  end

  # GET /asserted_distributions/1
  # GET /asserted_distributions/1.json
  def show
  end

  # GET /asserted_distributions/new
  def new
    @asserted_distribution = AssertedDistribution.new
  end

  # GET /asserted_distributions/1/edit
  def edit
  end

  # POST /asserted_distributions
  # POST /asserted_distributions.json
  def create
    @asserted_distribution = AssertedDistribution.new(asserted_distribution_params)
    respond_to do |format|
      if @asserted_distribution.save
        if params[:return_to]
          @lock_source = params['lock_source']
          source_id    = (@lock_source ? params[:source_id] : nil)
          format.html { redirect_to new_asserted_distribution_task_path(asserted_distribution: {
                                                                          otu_id:    @asserted_distribution.otu.to_param,
                                                                          source_id: source_id}),
                                    notice: 'Asserted distribution was successfully created.' }
        else
          format.html { redirect_to @asserted_distribution, notice: 'Asserted distribution was successfully created.' }
        end
        format.json { render :show, status: :created, location: @asserted_distribution }
      else
        format.html { render :new }
        format.json { render json: @asserted_distribution.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /asserted_distributions/1
  # PATCH/PUT /asserted_distributions/1.json
  def update
    respond_to do |format|
      if @asserted_distribution.update(asserted_distribution_params)
        format.html { redirect_to @asserted_distribution, notice: 'Asserted distribution was successfully updated.' }
        format.json { render :show, status: :ok, location: @asserted_distribution }
      else
        format.html { render :edit }
        format.json { render json: @asserted_distribution.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /asserted_distributions/1
  # DELETE /asserted_distributions/1.json
  def destroy
    @asserted_distribution.destroy
    respond_to do |format|
      format.html { redirect_to asserted_distributions_url, notice: 'Asserted distribution was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def list
    @asserted_distributions = AssertedDistribution.with_project_id($project_id).order(:id).page(params[:page]) #.per(10) #.per(3)
  end

  def autocomplete
    @asserted_distributions = AssertedDistribution.find_for_autocomplete(params.merge(project_id: sessions_current_project_id)) # in model
    data                    = @asserted_distributions.collect do |t|
      {id:              t.id,
       label:           AssertedDistributionsHelper.asserted_distribution_tag(t), # in helper
       response_values: {
         params[:method] => t.id
       },
       label_html:      AssertedDistributionsHelper.asserted_distribution_tag(t) #  render_to_string(:partial => 'shared/autocomplete/taxon_name.html', :object => t)
      }
    end
    render :json => data
  end


  def search
    if params[:id]
      redirect_to asserted_distribution_path(params[:id])
    else
      redirect_to asserted_distributions_path, notice: 'You must select an item from the list with a click or tab press before clicking show.'
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_asserted_distribution
    @asserted_distribution = AssertedDistribution.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def asserted_distribution_params
    params.require(:asserted_distribution).permit(:otu_id, :geographic_area_id, :source_id, :is_absent)
  end
end
