class Tasks::LoansController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  def complete
    @collection_objects = CollectionObject.where('false')
  end

  def add_determination
  end

  def return_items
  end

  def loan_items_list
    @loan       = Loan.find(params['loan_id'])
    @loan_items = @loan.loan_items
  end

  def find_loan_items(loan_id)
    # Loan.joins(:loan_items).where(loan_items: {loan_item_object_type: 'CollectionObject'})

    pile1 = Loan.joins(:loan_items).where(loan_items: {loan_id: loan_id})
  end
end
