class LoansController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :require_sign_in_and_project_selection
  before_action :set_loan, only: [:show, :edit, :update, :destroy, :recipient_form]

  # GET /loans
  # GET /loans.json
  def index
    @recent_objects = Loan.includes(:loan_items, :identifiers).recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
    render '/shared/data/all/index'
  end

  # GET /loans/1
  # GET /loans/1.json
  def show
  end

  # GET /loans/new
  def new
    @loan = Loan.new(params.permit(:clone_from))
  end

  # GET /loans/1/edit
  def edit
  end

  # POST /loans
  # POST /loans.json
  def create
    @loan = Loan.new(loan_params)

    respond_to do |format|
      if @loan.save
        format.html { redirect_to @loan, notice: 'Loan was successfully created.' }
        format.json { render :show, status: :created, location: @loan }
      else
        format.html { render :new }
        format.json { render json: @loan.errors, status: :unprocessable_entity }
      end
    end
  end

  def recipient_form
    render layout: 'us_letter'
  end

  # PATCH/PUT /loans/1
  # PATCH/PUT /loanss/1.json
  def update
    respond_to do |format|
      if @loan.update(loan_params)
        @loan.reload
        format.html { redirect_to @loan, notice: 'Loan was successfully updated.' }
        format.json { render :show, status: :ok, location: @loan }
      else
        format.html { render :edit }
        format.json { render json: @loan.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /loans/1
  # DELETE /loans/1.json
  def destroy
    @loan.destroy
    respond_to do |format|
      format.html { redirect_to loans_url }
      format.json { head :no_content }
    end
  end

  def list
    @loans = Loan.includes(:identifiers).with_project_id(sessions_current_project_id)
      .order(Arel.sql("LENGTH(identifier), identifier")).references(:identifiers).page(params[:page]) #.per(10) #.per(3)
  end

  def search
    if params[:id].blank?
      redirect_to loan_path, alert: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to loan_path(params[:id])
    end
  end

  def autocomplete
    @loans = Queries::Loan::Autocomplete.new(params[:term], project_id: sessions_current_project_id).autocomplete
  end

  # GET /loans/download
  def download
    send_data Export::Download.generate_csv(Loan.where(project_id: sessions_current_project_id)), type: 'text', filename: "loans_#{DateTime.now}.csv"
  end

  # GET /loans/select_options
  def select_options
    @loans = Loan.select_optimized(sessions_current_user_id, sessions_current_project_id)
  end

  private

  def set_loan
    @loan = Loan.with_project_id(sessions_current_project_id).find(params[:id])
    @recent_object = @loan
  end

  def loan_params
    params.require(:loan).permit(
      :date_requested, :request_method, :date_sent, :date_received,
      :date_return_expected, :recipient_person_id, :recipient_address,
      :recipient_email, :recipient_phone, :recipient_country, :supervisor_person_id,
      :supervisor_email, :supervisor_phone, :date_closed, :recipient_honorific,
      :lender_address,
      :clone_from,
      :is_gift,
      loan_items_attributes: [
        :_destroy,
        :id,
        :global_entity,
        :loan_item_object_type,
        :loan_item_object_id,
        :position,
        :total,
        :disposition,
        :date_,
        :date_returned_jquery ],
        roles_attributes: [
          :id, :_destroy, :type, :person_id, :position,
          person_attributes: [
            :last_name, :first_name, :suffix, :prefix]],
    )
  end
end
