class GeneAttributesController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_gene_attribute, only: [:show, :edit, :update, :destroy]

  # GET /gene_attributes
  # GET /gene_attributes.json
  def index
    @recent_objects = GeneAttribute.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
    render 'shared/data/all/index'
  end

  # GET /gene_attributes/1
  # GET /gene_attributes/1.json
  def show
  end

  # GET /gene_attributes/new
  def new
    @gene_attribute = GeneAttribute.new
  end

  # GET /gene_attributes/1/edit
  def edit
  end

  def list
    @gene_attributes = GeneAttribute.with_project_id(sessions_current_project_id).page(params[:page])
  end

  # POST /gene_attributes
  # POST /gene_attributes.json
  def create
    @gene_attribute = GeneAttribute.new(gene_attribute_params)

    respond_to do |format|
      if @gene_attribute.save
        format.html { redirect_to @gene_attribute, notice: 'Gene attribute was successfully created.' }
        format.json { render :show, status: :created, location: @gene_attribute }
      else
        format.html { render :new }
        format.json { render json: @gene_attribute.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /gene_attributes/1
  # PATCH/PUT /gene_attributes/1.json
  def update
    respond_to do |format|
      if @gene_attribute.update(gene_attribute_params)
        format.html { redirect_to @gene_attribute, notice: 'Gene attribute was successfully updated.' }
        format.json { render :show, status: :ok, location: @gene_attribute }
      else
        format.html { render :edit }
        format.json { render json: @gene_attribute.errors, status: :unprocessable_entity }
      end
    end
  end

  def search
    if params[:id].blank?
      redirect_to gene_attributes_path, notice: 'You must select an item from the list with a click or tab before clicking show.'
    else
      redirect_to gene_attribute_path(params[:id])
    end
  end

  # DELETE /gene_attributes/1
  # DELETE /gene_attributes/1.json
  def destroy
    @gene_attribute.destroy
    respond_to do |format|
      format.html { redirect_to gene_attributes_url, notice: 'Gene attribute was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_gene_attribute
      @gene_attribute = GeneAttribute.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def gene_attribute_params
      params.require(:gene_attribute).permit(:descriptor_id, :sequence_id, :sequence_relationship_type, :controlled_vocabulary_term_id, :position, :created_by_id, :updated_by_id, :project_id)
    end
end
