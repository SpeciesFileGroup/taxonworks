class LoanItemsController < ApplicationController
  include DataControllerConfiguration

  before_action :set_loan_item, only: [:edit, :update, :destroy]  # todo @mjy edit is action no view

  # GET /loan_items/new
  def new
    @loan_item = LoanItem.new
  end

  # GET /loan_items/1/edit
  def edit
  end

  # POST /loan_items
  # POST /loan_items.json
  def create
    @loan_item = LoanItem.new(loan_item_params)

    respond_to do |format|
      if @loan_item.save
        format.html { redirect_to :back, notice: 'Loan item was successfully created.' }
        format.json { render :show, status: :created, location: @loan_item }
      else
        format.html { redirect_to :back, notice: 'Loan item was NOT successfully created.' }
        format.json { render json: @loan_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /loan_items/1
  # PATCH/PUT /loan_items/1.json
  def update
    respond_to do |format|
      if @loan_item.update(loan_item_params)
        format.html { redirect_to @loan_item, notice: 'Loan item was successfully updated.' }
        format.json { render :show, status: :ok, location: @loan_item }
      else
        format.html { render :edit }
        format.json { render json: @loan_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /loan_items/1
  # DELETE /loan_items/1.json
  def destroy
    @loan_item.destroy
    respond_to do |format|
      format.html { redirect_to :back, notice: 'Loan item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_loan_item
      @loan_item = LoanItem.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def loan_item_params
      params.require(:loan_item).permit(:loan_id, :collection_object_id, :collection_object_status, :date_returned,
                                        :position, :container_id
      )
    end
end
