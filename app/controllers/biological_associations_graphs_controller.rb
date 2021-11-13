class BiologicalAssociationsGraphsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_biological_associations_graph, only: [:show, :edit, :update, :destroy]

  # GET /biological_associations_graphs
  # GET /biological_associations_graphs.json
  def index
    @recent_objects = BiologicalAssociationsGraph.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
    render '/shared/data/all/index'
  end

  # GET /biological_associations_graphs/1
  # GET /biological_associations_graphs/1.json
  def show
  end

  # GET /biological_associations_graphs/new
  def new
    @biological_associations_graph = BiologicalAssociationsGraph.new(origin_citation: Citation.new)
  end

  # GET /biological_associations_graphs/1/edit
  def edit
#    @biological_associations_graph.souce = Source.new if !@taxon_name.source
  end

  def list
    @biological_associations_graphs = BiologicalAssociationsGraph.with_project_id(sessions_current_project_id).order(:id).page(params[:page]) #.per(10)
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
      redirect_to biological_associations_graphs_path, alert: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to biological_association_graph_path(params[:id])
    end
  end
  
  private
  
  def set_biological_associations_graph
    @biological_associations_graph = BiologicalAssociationsGraph.where(project_id: sessions_current_project_id).find(params[:id])
  end

  def biological_associations_graph_params
    params.require(:biological_associations_graph).permit(
      :name,
      origin_citation_attributes: [:id, :_destroy, :source_id, :pages] 
    )
  end
end
