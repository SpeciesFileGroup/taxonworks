class ApiController < ApplicationController

  attr_accesor :permitted_projects

  before_filter :set_permitted_projects


  def index
    respond_to do |format|
      format.html {}

      format.json { 
        render(json: { success: true }, status: 200)
      }
    end
  end

  protected
  
  def set_permitted_projects
    @permitted_projects = @sessions_current_user.projects    
  end


end
