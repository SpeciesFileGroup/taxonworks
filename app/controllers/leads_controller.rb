class LeadsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration
  before_action :set_lead, only: %i[ edit update destroy show_all show_all_print destroy_couplet delete_couplet duplicate ]

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
          .order('description')
          .page(params[:page])
          .per(params[:per])
      }
    end
  end

  def list
    @leads = Lead.with_project_id(sessions_current_project_id).where('parent_id is null').order(:id).page(params[:page])
  end

  # GET /leads/1
  # GET /leads/1.json
  def show
    respond to do |format|
      format.html {
        id = params[:lead][:id] if params[:lead]
        id ||= params[:id]

        @lead = Lead.find(id)
        @lead = @lead.parent if params[:lead] and params[:lead][:id] # we hit this when we search, and in fact want to display the found lead, not its children

        children = @lead.children(order: :position)
        if children.size == 2
          @left = children[0]
          @right = children[1]
        end

        # TODO
        @left_text = Linker.new(:link_url_base => self.request.host, :proj_id => @proj.ontology_id_to_use, :incoming_text => @left.text, :adjacent_words_to_fuse => 5).linked_text(:is_public => false)
        @right_text = Linker.new(:link_url_base => self.request.host, :proj_id => @proj.ontology_id_to_use, :incoming_text => @right.text, :adjacent_words_to_fuse => 5).linked_text(:is_public => false)

        @left_future = @left.future
        @right_future = @right.future

        @parents = @lead.ancestors.reverse!
      }
      format.json
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
    @lead = Lead.new
  end

  # GET /leads/1/edit
  def edit
    children = @lead.children
    if children.size == 2
      @left = children[0]
      @right = children[1]
      @left_future = @left.future
      @right_future = @right.future
    else
      new_couplet
    end
    @parents = @lead.ancestors.reverse!
  end

  # POST /leads
  # POST /leads.json
  def create
    @lead = Lead.new(lead_params)
    respond_to do |format|
      if @lead.save
        new_couplet # we make two blank couplets so we can show the key
        format.html { redirect_to action: 'list', notice: 'Key was successfully created.' }
        format.json { render :show, status: :created, location: @lead }
      else
        format.html { redirect_to action: 'new', notice: 'Failed to create a new key!' }
        format.json { render json: @lead.errors, status: :unprocessable_entity}
      end
    end
  end

  def insert_couplet
    @lead = Lead.find(lead_params[:id]) or raise 'insert_couplet failed.'
    @lead.insert_couplet

    respond_to do |format|
      format.html { redirect_to action: :edit, id: @lead.parent_id, notice: 'Inserted a couplet.' }
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
        @left.update!(params[:left])
        @right.update!(params[:right])
        @lead.update!(params[:lead])
        format.html { redirect_to action: 'edit', id: @lead, notice: 'Successfully updated!' }
        format.json { render :show, status: :ok, location: @lead }
      rescue
        format.html { redirect_to action: 'edit', id: @lead, notice: 'Something went wrong in the save!' }
        format.json { render json: @lead.errors, status: :unprocessable_entity}
      end
    end
  end

  # DELETE /leads/1
  # DELETE /leads/1.json
  def destroy
    respond_to do |format|
      if no_grandchildren(@lead)
        @lead.destroy! # note we allow the AR to do this
        format.html { redirect_to action: 'list', notice: 'Deleted.' }
        format.json { head :no_content }
      else
        format.html { redirect_to action: 'list', notice: 'Node not deleted: can only delete nodes with no grandchildren.' }
        # TODO: what's the right response here, to say 'nothing went wrong, you just can't delete in this case'?
        format.json { head :no_content }
      end
    end
  end

  # For destroying a couplet with no children on either side.
  def destroy_couplet
    if @lead.parent_id.present?
      delete_couplet
    else
      respond_to do |format|
        format.html { redirect_to action: :edit, id: @lead, notice: 'Can\'t delete a root couplet.' }
        # TODO: ?
        format.json { head :no_content }
      end
    end
  end

  # For deleting a couplet where one side has no children but the other might; the side with children is reparented.
  def delete_couplet
    respond_to do |format|
      if @lead.destroy_couplet
        notice = @lead.children.size == 0 ? 'Deleted couplet and moved back up.' : 'Deleted couplet and reparented its children.'
        format.html { redirect_to action: :edit, id: @lead, notice: }
        format.json { head :no_content }
      else
        format.html { redirect_to action: :edit, id: @lead, notice: 'Couplet was not deleted.'}
        format.json { head :no_content }
      end
    end
    redirect_to action: :edit, id: (@lead.children.size == 0 ? @lead.parent_id : @lead)
  end

  def duplicate
    @lead.dupe
    respond_to do |format|
      format.html { redirect_to action: :list }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_lead
    @lead = Lead.find(params[:id])
  end

  def lead_params
    params.require(:lead).permit(:parent_id, :otu_id, :text, :origin_label, :description, :redirect_id, :link_out, :link_out_text, :position, :is_public)
  end

  def new_couplet
    # Assumes the parent node is @clave
    return if @clave.children.size == 0
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
