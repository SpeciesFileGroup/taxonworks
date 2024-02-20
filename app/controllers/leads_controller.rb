class LeadsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration
  before_action :set_lead, only: %i[
    edit create_for_edit update destroy show show_all show_all_print all_texts
    destroy_couplet insert_couplet delete_couplet duplicate update_meta ]

  # GET /leads
  # GET /leads.json
  def index
    respond_to do |format|
      format.html {
        @recent_objects = Lead.recent_from_project_id(sessions_current_project_id).where('parent_id is null').order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      }
      format.json {
        @leads = Lead.with_project_id(sessions_current_project_id)
          .where('parent_id is null')
          .order(:description)
          .page(params[:page])
          .per(params[:per])
      }
    end
  end

  def list
    @leads = Lead.with_project_id(sessions_current_project_id)
      .where('parent_id is null').order(:id).page(params[:page])
  end

  # GET /leads/1/all_texts.json
  def all_texts
    leads = Lead
      .select(:id, :text, :origin_label)
      .with_project_id(sessions_current_project_id)
      .order(:text)
    ancestor_ids = @lead.ancestor_ids
    @texts = leads.filter_map {|o|
      if o.id != @lead.id && !ancestor_ids.include?(o.id)
        {
          id: o.id,
          label: o.origin_label,
          text: o.text.nil? ? '' : o.text.truncate(40)
        }
      end
    }
  end

  # GET /leads/1
  # GET /leads/1.json
  def show
    children = @lead.children
    if children.size == 2
      expand_lead
    else
      @left = nil
      @right = nil
      @left_future = []
      @right_future = []
      @parents = @lead.ancestors.reverse
    end
  end

  def show_all
    @key = @lead.all_children
  end

  def show_all_print
    @key = @lead.all_children_standard_key
  end

  # GET /leads/new
  def new
    respond_to do |format|
      format.html { redirect_to new_lead_task_path }
      format.json {
        @lead = Lead.new
      }
    end
  end

  # GET /leads/1/edit
  def edit
    redirect_to new_lead_task_path id: @lead.id
  end

  # POST /leads/1/create_for_edit.json
  def create_for_edit
    if @lead.children.size == 0
      new_couplet
    end
    expand_lead
  end

  # POST /leads
  # POST /leads.json
  def create
    @lead = Lead.new(lead_params)
    respond_to do |format|
      if @lead.save
        new_couplet # we make two blank couplets so we can show the key
        expand_lead
        format.json {}
      else
        format.json { render json: @lead.errors, status: :unprocessable_entity}
      end
    end
  end

  # POST /leads/1.json/insert_couplet
  def insert_couplet
    @lead.insert_couplet

    respond_to do |format|
      format.json { head :no_content }
    end
  end

  # PATCH/PUT /leads/1
  # PATCH/PUT /leads/1.json
  def update
    @lead = Lead.find(params[:lead][:id])
    @left = Lead.find(params[:left][:id])
    @right = Lead.find(params[:right][:id])
    respond_to do |format|
      begin
        @lead.update!(lead_params)
        @left.update!(lead_params(:left))
        @right.update!(lead_params(:right))
        # Note that future changes when redirect is updated.
        expand_lead
        format.json {}
      rescue
        @lead.errors.merge!(@left)
        @lead.errors.merge!(@right)
        format.json { render json: @lead.errors, status: :unprocessable_entity}
      end
    end
  end

  # DELETE /leads/1
  # DELETE /leads/1.json
  def destroy
    if @lead.parent_id
      respond_to do |format|
        flash[:error] = 'Delete aborted - you can only delete on root nodes.'
        format.json { head :no_content, status: :unprocessable_entity }
      end
    else
      respond_to do |format|
        @lead.destroy! # note we allow the AR to do this
        flash[:notice] = 'Key deleted.'
        format.json { head :no_content }
      end
    end
  end

  # For destroying a couplet with no children on either side.
  def destroy_couplet
    if @lead.parent_id.present?
      delete_couplet
      respond_to do |format|
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.json { head :no_content, status: :unprocessable_entity }
      end
    end
  end

  # For deleting a couplet where one side has no children but the other might;
  # the side with children is reparented.
  def delete_couplet
    respond_to do |format|
      if @lead.destroy_couplet
        format.json { head :no_content }
      else
        format.json { head :no_content }
      end
    end
  end

  # POST /leads/1/duplicate
  def duplicate
    respond_to do |format|
      format.html {
        if !@lead.parent_id
          @lead.dupe
          flash[:notice] = 'Key cloned.'
        else
          flash[:error] = 'Clone aborted - you can only clone on a root node.'
        end
        redirect_to action: :list
      }
    end
  end

  # POST /leads/1/update_meta.json
  def update_meta
    respond_to do |format|
      if @lead.update(lead_params)
        format.json { head :no_content }
      else
        format.json { render json: @lead.errors, status: :unprocessable_entity}
      end
    end
  end

  def autocomplete
    @leads = ::Queries::Lead::Autocomplete.new(
      params.require(:term),
      project_id: sessions_current_project_id,
    ).autocomplete
  end

  def search
    if params[:id].blank?
      redirect_to(lead_path,
                  alert: 'You must select an item from the list with a click or tab press before clicking show.')
    else
      redirect_to lead_path(params[:id])
    end
  end

  private

  def set_lead
    @lead = Lead.find(params[:id])
  end

  def lead_params(require = :lead)
    params.require(require).permit(
      :otu_id, :text, :origin_label, :description, :redirect_id,
      :link_out, :link_out_text, :is_public, :position
    )
  end

  def expand_lead
    # Assumes the parent node is @lead and @lead has two children
    @left = @lead.children[0]
    @right = @lead.children[1]
    @left_future = @left.future
    @right_future = @right.future
    @parents = @lead.ancestors.reverse
  end

  def new_couplet
    # Assumes the parent node is @lead
    return if @lead.children.size > 0
    @left = @lead.children.create!
    @right = @lead.children.create!
    @left_future = @left.future
    @right_future =  @right.future
  end

  def no_grandchildren(lead)
    children = lead.children
    (children.size == 2) and (children[0].children.size == 0) and (children[1].children.size == 0)
  end
end
