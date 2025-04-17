class LeadItemsController < ApplicationController
  before_action :set_lead_item, only: %i[ show edit update destroy ]

  # GET /lead_items or /lead_items.json
  def index
    @lead_items = LeadItem.all
  end

  # GET /lead_items/1 or /lead_items/1.json
  def show
  end

  # GET /lead_items/new
  def new
    @lead_item = LeadItem.new
  end

  # GET /lead_items/1/edit
  def edit
  end

  # POST /lead_items or /lead_items.json
  def create
    @lead_item = LeadItem.new(lead_item_params)

    respond_to do |format|
      if @lead_item.save
        format.html { redirect_to @lead_item, notice: 'Lead item was successfully created.' }
        format.json { render :show, status: :created, location: @lead_item }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @lead_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lead_items/1 or /lead_items/1.json
  def update
    respond_to do |format|
      if @lead_item.update(lead_item_params)
        format.html { redirect_to @lead_item, notice: 'Lead item was successfully updated.' }
        format.json { render :show, status: :ok, location: @lead_item }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @lead_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lead_items/1 or /lead_items/1.json
  def destroy
    @lead_item.destroy!

    respond_to do |format|
      format.html { redirect_to lead_items_path, status: :see_other, notice: 'Lead item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def destroy_item_in_lead_and_descendants
    lead_ids = Lead.find(params[:lead_id]).self_and_descendant_ids
    begin
      LeadItem.transaction do
        LeadItem
          .where(lead_id: lead_ids, otu_id: params[:otu_id])
          .destroy_all
      end
    rescue ActiveRecord::RecordNotDestroyed => e
      errors.add(:base, "Destroy lead items failed! '#{e}'")
      return false
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
  def set_lead_item
    @lead_item = LeadItem.find(params[:id])
  end

    # Only allow a list of trusted parameters through.
  def lead_item_params
    params.require(:lead_item).permit(:lead_id, :otu_id, :project_id, :created_by_id, :updated_by_id, :position)
  end
end
