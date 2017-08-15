class UserPreferencesController < ApplicationController
  before_action :require_sign_in_and_project_selection

  def favorite_page
    sessions_current_user.add_page_to_favorites(valid_params)
    respond_to do |format|
      format.html {
        redirect_back(fallback_location: (request.referer || root_path), notice: 'Added page to favorites.')
      }
      format.js {
         }
    end
  end

  def unfavorite_page
    sessions_current_user.remove_page_from_favorites(valid_params)
    respond_to do |format|
      format.html {
        redirect_back(fallback_location: (request.referer || root_path), notice: 'Removed page from favorites.')
      }
      format.js { 
          }
    end
  end

  protected

  def valid_params
    params.permit(:name, :kind).merge(project_id: sessions_current_project_id)
  end

end
