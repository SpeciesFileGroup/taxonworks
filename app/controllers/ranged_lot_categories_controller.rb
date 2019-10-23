class RangedLotCategoriesController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_ranged_lot_category, only: [:show, :edit, :update, :destroy]

  # GET /ranged_lot_categories
  # GET /ranged_lot_categories.json
  def index
    @recent_objects = RangedLotCategory.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
    render '/shared/data/all/index'
  end

  # GET /ranged_lot_categories/1
  # GET /ranged_lot_categories/1.json
  def show
  end

  # GET /ranged_lot_categories/new
  def new
    @ranged_lot_category = RangedLotCategory.new
  end

  # GET /ranged_lot_categories/1/edit
  def edit
  end

  # POST /ranged_lot_categories
  # POST /ranged_lot_categories.json
  def create
    @ranged_lot_category = RangedLotCategory.new(ranged_lot_category_params)

    respond_to do |format|
      if @ranged_lot_category.save
        format.html { redirect_to @ranged_lot_category, notice: 'Ranged lot category was successfully created.' }
        format.json { render :show, status: :created, location: @ranged_lot_category }
      else
        format.html { render :new }
        format.json { render json: @ranged_lot_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ranged_lot_categories/1
  # PATCH/PUT /ranged_lot_categories/1.json
  def update
    respond_to do |format|
      if @ranged_lot_category.update(ranged_lot_category_params)
        format.html { redirect_to @ranged_lot_category, notice: 'Ranged lot category was successfully updated.' }
        format.json { render :show, status: :ok, location: @ranged_lot_category }
      else
        format.html { render :edit }
        format.json { render json: @ranged_lot_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ranged_lot_categories/1
  # DELETE /ranged_lot_categories/1.json
  def destroy
    @ranged_lot_category.destroy
    respond_to do |format|
      format.html { redirect_to ranged_lot_categories_url }
      format.json { head :no_content }
    end
  end

  def list
    @ranged_lot_categories = RangedLotCategory.with_project_id(sessions_current_project_id).order(:id).page(params[:page])
  end

  # GET /ranged_lot_categories/download
  def download
    send_data(Export::Download.generate_csv(RangedLotCategory.where(project_id: sessions_current_project_id)),
              type: 'text',
              filename: "ranged_lot_categories_#{DateTime.now}.csv")
  end


  private

  # Use callbacks to share common setup or constraints between actions.
  def set_ranged_lot_category
    @ranged_lot_category = RangedLotCategory.with_project_id(sessions_current_project_id).find(params[:id])
    @recent_object = @ranged_lot_category
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def ranged_lot_category_params
    params.require(:ranged_lot_category).permit(:name, :minimum_value, :maximum_value)
  end
end
