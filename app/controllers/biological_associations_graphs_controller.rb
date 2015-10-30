class BiologicalAssociationsGraphsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_biological_associations_graph, only: [:show, :edit, :update, :destroy]

  # GET /biological_associations_graphs
  # GET /biological_associations_graphs.json
  def index
    @recent_objects = BiologicalAssociationsGraph.recent_from_project_id($project_id).order(updated_at: :desc).limit(10)
    render '/shared/data/all/index'
  end

  # GET /biological_associations_graphs/1
  # GET /biological_associations_graphs/1.json
  def show
  end

  # GET /biological_associations_graphs/new
  def new
    @biological_associations_graph = BiologicalAssociationsGraph.new
  end

  # GET /biological_associations_graphs/1/edit
  def edit
  end

  def list
    @biological_associations_graphs = BiologicalAssociationsGraph.with_project_id($project_id).order(:id).page(params[:page]) #.per(10)
  end

  # POST /biological_associations_graphs
  # POST /biological_associations_graphs.json
  def create
    @biological_associations_graph = BiologicalAssociationsGraph.new(biological_associations_graph_params)

    respond_to do |format|
      if @biological_associations_graph.save
        format.html { redirect_to @biological_associations_graph, notice: 'Biological associations graph was successfully created.' }
        format.json { render :show, status: :created, location: @biological_associations_graph }
      else
        format.html { render :new }
        format.json { render json: @biological_associations_graph.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /biological_associations_graphs/1
  # PATCH/PUT /biological_associations_graphs/1.json
  def update
    respond_to do |format|
      if @biological_associations_graph.update(biological_associations_graph_params)
        format.html { redirect_to @biological_associations_graph, notice: 'Biological associations graph was successfully updated.' }
        format.json { render :show, status: :ok, location: @biological_associations_graph }
      else
        format.html { render :edit }
        format.json { render json: @biological_associations_graph.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /biological_associations_graphs/1
  # DELETE /biological_associations_graphs/1.json
  def destroy
    @biological_associations_graph.destroy
    respond_to do |format|
      format.html { redirect_to biological_associations_graphs_url, notice: 'Biological associations graph was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def search
    if params[:id].blank?
      redirect_to biological_associations_graphs_path, notice: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to biological_association_graph_path(params[:id])
    end
  end

  def autocomplete
    @biological_associations_graphs = BiologicalAssociationsGraph.find_for_autocomplete(params.merge(project_id: sessions_current_project_id))
    data = @biological_associations_graphs.collect do |t|
      {id: t.id,
       label: ApplicationController.helpers.biological_associations_graph_tag(t),
       response_values: {
           params[:method] => t.id
       },
       label_html: ApplicationController.helpers.biological_associations_graph_autocomplete_selected_tag(t)
      }
    end

    render :json => data
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_biological_associations_graph
    @biological_associations_graph = BiologicalAssociationsGraph.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def biological_associations_graph_params
    params.require(:biological_associations_graph).permit(:created_by_id, :updated_by_id, :project_id, :name, :source_id)
  end
end
