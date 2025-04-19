class LeadItemsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_lead_item, only: %i[ show edit update destroy ]

  # GET /lead_items or /lead_items.json
  def index
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

  def destroy_item_in_children
    lead_ids = Lead.find(params[:parent_id]).children.map(&:id)
    # Only one child should ever have the lead_item we're looking for, the
    # following is just the most economical way of finding and destroying it.
    begin
      LeadItem
        .where(lead_id: lead_ids, otu_id: params[:otu_id])
        .destroy_all
    rescue ActiveRecord::RecordNotDestroyed => e
      errors.add(:base, "Destroy lead item failed! '#{e}'")
      return false
    end
  end

  def add_lead_item_to_child_lead
    parent = Lead.find(params[:parent_id])
    otu_id = params[:otu_id]
    parent.children.to_a.reverse.each do |c|
      if c.lead_items.exists?
        otu_exists = c.lead_items.to_a.any? { |li| li.otu_id == otu_id }
        if otu_exists
          parent.errors.add(:base, 'Otu is already on the list!')
          render json: parent.errors, status: :unprocessable_entity
          return
        end

        LeadItem.create!(lead_id: c.id, otu_id:)
        head :no_content
        return
      end
    end

    parent.errors.add(:base, "Couldn't find a lead to add LeadItem to!")
    render json: parent.errors, status: :unprocessable_entity
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
