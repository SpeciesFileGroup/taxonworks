class DashboardController < ApplicationController

  # GET '/'
  def index
    redirect_to signin_path, status: 301 and return unless sessions_signed_in?
    @page_title = 'Your dashboard'
  end

end
