class Tasks::LoansController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_objects, only: [:complete, :update_status, :return_items, :add_determination]

  def complete
    @loan                = Loan.find(params['id'])
    @taxon_determination = TaxonDetermination.new()
    @loan_item           = LoanItem.new(loan: @loan)
  end

  def update_status
    if params[:disposition].blank?
      flash[:notice] = "Select a status first."
    else
      if LoanItem.batch_update_attribute(ids: loan_item_ids_params, attribute: :disposition, value: params.fetch(:disposition))
        flash[:notice] = "Updated status of #{loan_item_ids_params.count} records."
      else
        flash[:notice] = "Failed to update #{loan_item_ids_params.count} records."
      end
    end

    render :complete
  end

  def return_items
    if params[:date_returned].blank?
      flash[:notice] = "Select a return date first."
    else
      if LoanItem.batch_update_attribute(ids: loan_item_ids_params, attribute: :date_returned, value: params.fetch(:date_returned))
        flash[:notice] = "Updated return of #{loan_item_ids_params.count} records."
      else
        flash[:notice] = "Failed to update #{loan_item_ids_params.count} records."
      end
    end

    render :complete
  end

  def add_determination
    if LoanItem.batch_determine_loan_items(ids: loan_item_ids_params, params: taxon_determination_params)
      flash[:notice] = "Updated determinations."
    else
      flash[:notice] = "Failed to update #{loan_item_ids_params.count} records."
    end

    render :complete
  end

  private

  def set_objects
    @loan                = Loan.find(params['id'])
    @taxon_determination = TaxonDetermination.new()
  end

  def loan_item_ids_params
    items = params.permit(loan_items: [:id])[:loan_items]
    items ? items.collect { |k, v| v['id'] } : []
  end

  def taxon_determination_params
    params.require(:taxon_determination).permit(:biological_collection_object_id,
                                                :otu_id,
                                                :year_made,
                                                :month_made,
                                                :day_made,
                                                roles_attributes: [:id,
                                                                   :_destroy,
                                                                   :type,
                                                                   :person_id,
                                                                   :position,
                                                                   person_attributes: [:last_name,
                                                                                       :first_name,
                                                                                       :suffix,
                                                                                       :prefix]],
                                                otu_attributes:   [:id,
                                                                   :_destroy,
                                                                   :name,
                                                                   :taxon_name_id]
    )
  end

end
