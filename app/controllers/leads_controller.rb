class LeadsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration
  before_action :set_lead, only: %i[
    edit add_children update destroy show
    redirect_option_texts destroy_children insert_couplet delete_children
    duplicate otus destroy_subtree reorder_children insert_key
    set_observation_matrix reset_lead_items
  ]

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
      @lead_item_otus = @lead.apportioned_lead_item_otus
    end
  end

  # GET /leads/new
  def new
    redirect_to new_lead_task_path
  end

  # GET /leads/1/edit
  def edit
    redirect_to new_lead_task_path lead_id: @lead.id
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
        format.json { render json: @lead.errors, status: :unprocessable_content}
      end
    end
  end

  # POST /leads/1/add_children.json
  def add_children
    num_to_add = params[:num_to_add]
    if num_to_add < 1 || num_to_add > 2
      @lead.errors.add(:add_children,
        "request must be for 1 or 2, was '#{num_to_add}'"
      )
      render json: @lead.errors, status: :unprocessable_content
      return
    end

    # currently infers num_to_add
    @lead.add_children(sessions_current_project_id, sessions_current_user_id)
    expand_lead
    render action: :show, status: :created, location: @lead
  end

  # POST /leads/1/insert_couplet.json
  def insert_couplet
    @lead.insert_couplet
    head :no_content
  end

  # PATCH/PUT /leads/1.json
  def update
    begin
      @lead.update!(lead_params)
      @lead_item_otus = @lead.parent_id ?
        @lead.parent.apportioned_lead_item_otus :
        { parent: [], children: [] }
    rescue ActiveRecord::RecordInvalid
      render json: @lead.errors, status: :unprocessable_content
    end
  end

  # DELETE /leads/1
  # DELETE /leads/1.json
  def destroy
    if @lead.parent_id
      respond_to do |format|
        flash[:error] = 'Delete aborted - you can only delete on root nodes.'
        format.html { redirect_back(fallback_location: (request.referer || root_path)) }
        format.json { head :no_content, status: :unprocessable_content }
      end
      return
    end

    begin
      @lead.transaction_nuke
      respond_to do |format|
        flash[:notice] = 'Key was successfully destroyed.'
        format.html { destroy_redirect @lead }
        format.json { head :no_content }
      end
    rescue ActiveRecord::RecordInvalid
      respond_to do |format|
        flash[:error] = 'Delete failed!'
        format.html { redirect_back(fallback_location: (request.referer || root_path)) }
        format.json { render json: @lead.errors, status: :unprocessable_content }
      end
    end
  end

  # A separate action from destroy to be called in different contexts: this one
  # can be called on any lead, not just root.
  # POST /leads/1/destroy_subtree.json
  def destroy_subtree
    parent = @lead.parent
    begin
      Lead.destroy_lead_and_descendants(
        @lead, sessions_current_project_id, sessions_current_user_id
      )
    rescue TaxonWorks::Error => e
      parent.errors.add(:error, e)
      render json: parent.errors, status: :unprocessable_content
      return
    end

    @lead = parent.reload
    expand_lead
    render :show, status: :ok, location: @lead
  end

  # For destroying all children at a particular level of the key where none of
  # the children have their own children.
  def destroy_children
    if @lead.parent_id.present?
      if @lead.destroy_children
        head :no_content
      else
        @lead.errors.add(:delete, 'failed!')
        render json: @lead.errors, status: :unprocessable_content
      end
    else
      @lead.errors.add(:destroy, "failed - can't delete the only couplet.")
      render json: @lead.errors, status: :unprocessable_content
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
          render json: @lead.errors, status: :unprocessable_content
        }
      end
    end
  end

  # POST /leads/1/duplicate.html
  def duplicate
    respond_to do |format|
      format.html {
        if !@lead.parent_id
          if @lead.dupe
            flash[:notice] = 'Key cloned.'
          else
            flash[:error] = @lead.errors.full_messages.join('; ')
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
    if !@lead.insert_key(params[:key_to_insert])
      render json: @lead.errors, status: :unprocessable_content
      return
    end

    head :no_content
  end

  # PATCH /leads/1/reorder_children.json
  def reorder_children
    begin
      @lead.reorder_children(reorder_params[:reorder_list])
    rescue TaxonWorks::Error => e
      @lead.errors.add(:reorder_failed, e.to_s)
      render json: @lead.errors, status: :unprocessable_content
      return
    end

    @leads = @lead.reload.children
    @lead_item_otus = @lead.apportioned_lead_item_otus
  end

  # GET /leads/1/otus.json
  def otus
    @otus = Otu.associated_with_key(@lead)
  end

  def remaining_otus
    lead = Lead.find(params[:id])

    @otus = lead.remaining_otus

    render '/leads/otus'

  end

  def eliminated_otus
    lead = Lead.find(params[:id])

    @otus = lead.eliminated_otus

    render '/leads/otus'

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

  # Creates a new key populated with otus from params[:otu_query].
  def batch_create_lead_items
    @lead = Lead.create!(params.require(:lead).permit(:text))
    @lead.batch_populate_lead_items(params[:otu_query],
      sessions_current_project_id, sessions_current_user_id
    )

    @lead.add_children(sessions_current_project_id, sessions_current_user_id)

    render json: @lead
  end

  def reset_lead_items
    @lead.reset_lead_items

    head :no_content
  end

  def set_observation_matrix
    if params[:observation_matrix_id].nil?
      @lead.errors.add(:observation_matrix_id, 'is required.')
      render json: @lead.errors, status: :unprocessable_content
    end

    @lead.update!(observation_matrix_id: params[:observation_matrix_id])
    head :no_content
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

  def reorder_params
    params.permit(reorder_list: [])
  end

  def expand_lead
    @children = @lead.children
    @lead_item_otus = @lead.apportioned_lead_item_otus
  end

  def new_couplet
    2.times do
      @lead.children.create!
    end
  end

end
