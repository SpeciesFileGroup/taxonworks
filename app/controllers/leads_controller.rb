class LeadsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration
  before_action :set_lead, only: %i[
    edit create_for_edit update destroy show show_all show_all_print
    redirect_option_texts destroy_children insert_couplet delete_children
    duplicate update_meta otus destroy_subtree swap insert_key]

  # GET /leads
  # GET /leads.json
  def index
    respond_to do |format|
      format.html {
        one_week_ago = Time.now.utc.to_date - 7
        @recent_objects = Lead
          .roots_with_data(sessions_current_project_id)
          .where('key_updated_at > ?', one_week_ago)
          .reorder(key_updated_at: :desc)
          .limit(10)

        render '/shared/data/all/index'
      }
      format.json {
        if params[:load_root_otus]
          @leads = Lead.roots_with_data(sessions_current_project_id, true)
        else
          @leads = Lead.roots_with_data(sessions_current_project_id)
        end
      }
    end
  end

  def list
    @leads = Lead.
      roots_with_data(sessions_current_project_id).page(params[:page])
  end

  # GET /leads/1/redirect_option_texts.json
  def redirect_option_texts
    @texts = @lead.redirect_options(sessions_current_project_id)
  end

  # GET /leads/1
  # GET /leads/1.json
  def show
    if @lead.children.present?
      expand_lead
    else
      @children = nil
      @futures = nil
      @ancestors = @lead.ancestors.reverse
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
    redirect_to new_lead_task_path
  end

  # GET /leads/1/edit
  def edit
    redirect_to new_lead_task_path lead_id: @lead.id
  end

  # POST /leads/1/create_for_edit.json
  def create_for_edit
    if @lead.children.size == 0
      new_couplet
    end
    expand_lead
    render action: :show, status: :created, location: @lead
  end

  # POST /leads
  # POST /leads.json
  def create
    @lead = Lead.new(lead_params)
    respond_to do |format|
      if @lead.save
        new_couplet # we make a blank couplet so we can show the key
        expand_lead
        format.json { render action: :show, status: :created, location: @lead }
      else
        format.json { render json: @lead.errors, status: :unprocessable_entity}
      end
    end
  end

  # POST /leads/1/insert_couplet.json
  def insert_couplet
    @lead.insert_couplet
    head :no_content
  end

  # PATCH/PUT /leads/1.json
  def update
    @lead = Lead.find(params[:lead][:id])
    begin
      @lead.update!(lead_params)
      # Note that future changes when redirect is updated.
      @future = @lead.future
    rescue ActiveRecord::RecordInvalid
      render json: @lead.errors, status: :unprocessable_entity
    end
  end

  # DELETE /leads/1
  # DELETE /leads/1.json
  def destroy
    if @lead.parent_id
      respond_to do |format|
        flash[:error] = 'Delete aborted - you can only delete on root nodes.'
        format.html { redirect_back(fallback_location: (request.referer || root_path)) }
        format.json { head :no_content, status: :unprocessable_entity }
      end
      return
    end

    begin
      @lead.transaction_nuke
      respond_to do |format|
        flash[:notice] = 'Key was succesfully destroyed.'
        format.html { destroy_redirect @lead }
        format.json { head :no_content }
      end
    rescue ActiveRecord::RecordInvalid
      respond_to do |format|
        flash[:error] = 'Delete failed!'
        format.html { redirect_back(fallback_location: (request.referer || root_path)) }
        format.json { render json: @lead.errors, status: :unprocessable_entity }
      end
    end
  end

  # A separate action from destroy to be called in different contexts: this one
  # can be called on any lead, not just root.
  # POST /leads/1/destroy_subtree.json
  def destroy_subtree
    begin
      @lead.transaction_nuke
    rescue ActiveRecord::RecordInvalid
      render json: @lead.errors, status: :unprocessable_entity
    end

    head :no_content
  end

  # For destroying all children at a particular level of the key where none of
  # the children have their own children.
  def destroy_children
    respond_to do |format|
      if @lead.parent_id.present?
        if @lead.destroy_children
          format.json { head :no_content }
        else
          @lead.errors.add(:delete, 'failed!')
          format.json {
            render json: @lead.errors, status: :unprocessable_entity
          }
        end
      else
        @lead.errors.add(:destroy, "failed - can't delete the only couplet.")
        format.json {
          render json: @lead.errors, status: :unprocessable_entity
        }
      end
    end
  end

  # For deleting all children at a particular level of the key where at most one
  # of the children has its own children; the grandchildren, if any, are
  # reparented.
  def delete_children
    respond_to do |format|
      if @lead.destroy_children
        format.json { head :no_content }
      else
        @lead.errors.add(:delete, 'failed!')
        format.json {
          render json: @lead.errors, status: :unprocessable_entity
        }
      end
    end
  end

  # POST /leads/1/add_lead.json
  def add_lead
    parent = Lead.find(params[:id])
    @lead = parent.children.create!
  end

  # POST /leads/1/duplicate.html
  def duplicate
    respond_to do |format|
      format.html {
        if !@lead.parent_id
          rv = @lead.dupe
          if rv != true
            flash[:error] = rv
          else
            flash[:notice] = 'Key cloned.'
          end
        else
          flash[:error] = 'Clone aborted - you can only clone on a root node.'
        end

        redirect_to action: :list
      }
    end
  end

  # POST /leads/1/insert_key.json?key_to_insert=:id
  def insert_key
    rv = @lead.insert_key(params[:key_to_insert])
    if rv != true
      @lead.errors.add(:insert_key, "failed: '#{rv}'")
      render json: @lead.errors, status: :unprocessable_entity
      return
    end

    head :no_content
  end

  # PATCH /leads/1/update_meta.json
  def update_meta
    respond_to do |format|
      if @lead.update(lead_params)
        format.json {}
      else
        format.json { render json: @lead.errors, status: :unprocessable_entity}
      end
    end
  end

  # PATCH /leads/1/swap.json
  def swap
    swap_result = @lead.swap(params['direction'])
    if swap_result[:leads].empty?
      @lead.errors.add(:swap, 'failed, attempted to move lead off the end')
      render json: @lead.errors, status: :unprocessable_entity
      return
    end

    @leads = swap_result[:leads]
    @positions = swap_result[:positions]
    @futures = @leads.map(&:future)
  end

  # GET /leads/1/otus.json
  def otus
    leads_list = @lead.self_and_descendants.where.not(otu_id: nil).includes(:otu)

    @otus = leads_list.to_a.map(&:otu).uniq(&:id)
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

  # GET /leads/download
  def download
    send_data Export::CSV.generate_csv(
        Lead.where(project_id: sessions_current_project_id)
      ),
      type: 'text',
      filename: "leads_#{DateTime.now}.tsv"
  end

  def api_key
    @lead = Lead.where(project_id: sessions_current_project_id, is_public: true).find(params.require(:id))
    render '/leads/api/v1/key'
  end

  private

  def set_lead
    @lead = Lead.find(params[:id])
  end

  def lead_params()
    params.require(:lead).permit(
      :parent_id,
      :otu_id, :text, :origin_label, :description, :redirect_id,
      :link_out, :link_out_text, :is_public, :position
    )
  end

  def expand_lead
    @children = @lead.children
    @futures = @lead.children.map(&:future)
    @ancestors = @lead.ancestors.reverse
  end

  def new_couplet
    2.times do
      @lead.children.create!
    end
  end

end
