class Tasks::Loans::DashboardController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @loan_query = ::Queries::Loan::Filter.new(params) 
    @loans = @loan_query.all
  end

end