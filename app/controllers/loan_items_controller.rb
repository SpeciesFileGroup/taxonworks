class LoanItemsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_loan_item, only: [:update, :destroy, :show, :edit]

  # GET /loan_items
  # GET /loan_items.json
  def index
    respond_to do |format|
      format.html {
        @recent_objects = LoanItem.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      }
      format.json {
        @loan_items = LoanItem.where(filter_params).with_project_id(sessions_current_project_id)
      }
    end
  end

  # GET /loan_items/1
  # GET /loan_items/1.json
  def show
  end

  # GET /loan_items/new
  def new
    @loan_item = LoanItem.new(loan: Loan.new)
  end

  # GET /loan_items/1/edit
  def edit
  end

  def list
    @loan_items = LoanItem.with_project_id(sessions_current_project_id).order(:id).page(params[:page]) #.per(10)
  end

  # POST /loan_items
  # POST /loan_items.json
  def create
    @loan_item = LoanItem.new(loan_item_params)
    respond_to do |format|
      if @loan_item.save
        format.html {redirect_back(fallback_location: (request.referer || root_path), notice: 'Loan item was successfully created.')}
        format.json { render :show, status: :created, location: @loan_item }
      else
        format.html {redirect_back(fallback_location: (request.referer || root_path), notice: 'Loan item was NOT successfully created.')}
        format.json { render json: @loan_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /loan_items/1
  # PATCH/PUT /loan_items/1.json
  def update
    respond_to do |format|
      if @loan_item.update(loan_item_params)
        format.html { redirect_back(fallback_location: (request.referer || root_path), notice: 'Loan item was successfully updated.')}
        format.json { render :show, status: :ok, location: @loan_item }
      else
        format.html { redirect_back(fallback_location: (request.referer || root_path), notice: 'Loan item was NOT successfully updated.' + @loan_item.errors.full_messages.join('; '))}
        format.json { render json: @loan_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /loan_items/1
  # DELETE /loan_items/1.json
  def destroy
    @loan_item.destroy
    respond_to do |format|
      format.html { destroy_redirect @loan_item, notice: 'Loan item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def search
    if params[:id].blank?
      redirect_to loan_items_path, notice: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to loan_item_path(params[:id])
    end
  end

  def autocomplete
    @loan_items = LoanItem.find_for_autocomplete(params.merge(project_id: sessions_current_project_id)).includes(:taxon_name)
    data = @loan_items.collect do |t|
      {id: t.id,
       label: ApplicationController.helpers.loan_item_tag(t),
       response_values: {
         params[:method] => t.id
       },
       label_html: ApplicationController.helpers.loan_item_autocomplete_selected_tag(t)
      }
    end

    render json: data
  end

  # POST /loan_items/batch_create?batch_type=tags&loan_id=123&keyword_id=456&klass=Otu
  # POST /loan_items/batch_create?batch_type=pinboard&loan_id=123&klass=Otu
  def batch_create
    if @loan_items = LoanItem.batch_create(batch_params)
      render :index
    else
      render json: {success: false}
    end 
  end

  private

  def filter_params
    params.permit(:loan_id)
  end 

  def set_loan_item
    @loan_item = LoanItem.with_project_id(sessions_current_project_id).find(params[:id])
  end

  def batch_params
    params.permit(:batch_type, :loan_id, :keyword_id, :klass).to_h.symbolize_keys.merge(project_id: sessions_current_project_id, user_id: sessions_current_user_id)
  end

  def loan_item_params
    params.require(:loan_item).permit(
      :loan_id, :collection_object_status, :date_returned, :loan_item_object_id, :loan_item_object_type,
      :date_returned_jquery, :disposition, :total,  
      :global_entity,
      :position
    )
  end
end
