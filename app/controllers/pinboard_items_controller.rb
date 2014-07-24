class PinboardItemsController < ApplicationController
  before_action :set_pinboard_item, only: [:show, :edit, :update, :destroy]

  # GET /pinboard_items
  # GET /pinboard_items.json
  def index
    @pinboard_items = PinboardItem.all
  end

  # GET /pinboard_items/1
  # GET /pinboard_items/1.json
  def show
  end

  # GET /pinboard_items/new
  def new
    @pinboard_item = PinboardItem.new
  end

  # GET /pinboard_items/1/edit
  def edit
  end

  # POST /pinboard_items
  # POST /pinboard_items.json
  def create
    @pinboard_item = PinboardItem.new(pinboard_item_params)

    respond_to do |format|
      if @pinboard_item.save
        format.html { redirect_to @pinboard_item, notice: 'Pinboard item was successfully created.' }
        format.json { render :show, status: :created, location: @pinboard_item }
      else
        format.html { render :new }
        format.json { render json: @pinboard_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pinboard_items/1
  # PATCH/PUT /pinboard_items/1.json
  def update
    respond_to do |format|
      if @pinboard_item.update(pinboard_item_params)
        format.html { redirect_to @pinboard_item, notice: 'Pinboard item was successfully updated.' }
        format.json { render :show, status: :ok, location: @pinboard_item }
      else
        format.html { render :edit }
        format.json { render json: @pinboard_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pinboard_items/1
  # DELETE /pinboard_items/1.json
  def destroy
    @pinboard_item.destroy
    respond_to do |format|
      format.html { redirect_to pinboard_items_url, notice: 'Pinboard item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pinboard_item
      @pinboard_item = PinboardItem.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def pinboard_item_params
      params.require(:pinboard_item).permit(:pinned_object_id, :pinned_object_type, :user_id, :project_id, :position, :is_inserted, :is_cross_project, :inserted_count, :created_by_id, :updated_by_id)
    end
end
