class MatrixRowItemsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_matrix_row_item, only: [:show, :edit, :update, :destroy]

  # GET /matrix_row_items
  # GET /matrix_row_items.json
   def index
     @recent_objects = MatrixRowItem.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
     render '/shared/data/all/index'
   end

  # GET /matrix_row_items/1
  # GET /matrix_row_items/1.json
  def show
  end

  def list
    @matrix_row_items = MatrixRow.with_project_id(sessions_current_project_id).page(params[:page])
  end

  # GET /matrix_row_items/new
  def new
    @matrix_row_item = MatrixRowItem.new
  end

  # GET /matrix_row_items/1/edit
  def edit
  end

  # POST /matrix_row_items
  # POST /matrix_row_items.json
  def create
    @matrix_row_item = MatrixRowItem.new(matrix_row_item_params)

    respond_to do |format|
      if @matrix_row_item.save
        format.html { redirect_to @matrix_row_item.metamorphosize, notice: 'Matrix row item was successfully created.' }
        format.json { render :show, status: :created, location: @matrix_row_item }
      else
        format.html { render :new }
        format.json { render json: @matrix_row_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /matrix_row_items/1
  # PATCH/PUT /matrix_row_items/1.json
  def update
    respond_to do |format|
      if @matrix_row_item.update(matrix_row_item_params)
        format.html { redirect_to @matrix_row_item.metamorphosize, notice: 'Matrix row item was successfully updated.' }
        format.json { render :show, status: :ok, location: @matrix_row_item }
      else
        format.html { render :edit }
        format.json { render json: @matrix_row_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /matrix_row_items/1
  # DELETE /matrix_row_items/1.json
  def destroy
    @matrix_row_item.destroy
    respond_to do |format|
      format.html { redirect_to matrix_row_items_url, notice: 'Matrix row item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_matrix_row_item
      @matrix_row_item = MatrixRowItem.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def matrix_row_item_params
      params.require(:matrix_row_item).permit(:matrix_id, :type, :collection_object_id, :otu_id, :controlled_vocabulary_term_id, :created_by_id, :updated_by_id, :project_id)
    end
end
