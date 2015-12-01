class DocumentationController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_documentation, only: [:show, :edit, :update, :destroy]

  # GET /documentation
  # GET /documentation.json
  def index
    @documentation = Documentation.all
  end

  # GET /documentation/1
  # GET /documentation/1.json
  def show
  end

  # GET /documentation/new
  def new
    @documentation = Documentation.new
  end

  # GET /documentation/1/edit
  def edit
  end

  # POST /documentation
  # POST /documentation.json
  def create
    @documentation = Documentation.new(documentation_params)

    respond_to do |format|
      if @documentation.save
        format.html { redirect_to @documentation, notice: 'Documentation was successfully created.' }
        format.json { render :show, status: :created, location: @documentation }
      else
        format.html { render :new }
        format.json { render json: @documentation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /documentation/1
  # PATCH/PUT /documentation/1.json
  def update
    respond_to do |format|
      if @documentation.update(documentation_params)
        format.html { redirect_to @documentation, notice: 'Documentation was successfully updated.' }
        format.json { render :show, status: :ok, location: @documentation }
      else
        format.html { render :edit }
        format.json { render json: @documentation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /documentation/1
  # DELETE /documentation/1.json
  def destroy
    @documentation.destroy
    respond_to do |format|
      format.html { redirect_to documentation_index_url, notice: 'Documentation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_documentation
      @documentation = Documentation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def documentation_params
      params.require(:documentation).permit(:documentation_object_id, :documentation_object_type, :document_id, :page_map, :project_id, :created_by_id, :updated_by_id)
    end
end
