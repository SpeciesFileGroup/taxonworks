class Tasks::Loans::OverdueController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @loans = Loan.overdue.with_project_id(sessions_current_project_id).order('date_return_expected DESC, date_sent ASC')
  end

end
