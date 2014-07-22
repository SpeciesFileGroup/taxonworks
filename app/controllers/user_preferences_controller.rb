class UserPreferencesController < ApplicationController
  before_action :require_sign_in_and_project_selection

  def favorite_page
    @sessions_current_user.add_page_to_favorites(params[:favorited_route])
    redirect_to :back, notice: 'Added page to favorites.'
  end

  protected

  def valid_params
    params.require(:favorited_route).permit(:favorited_route)
  end

end
