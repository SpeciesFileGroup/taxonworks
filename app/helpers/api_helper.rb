module ApiHelper

  def open_api_projects
    Project.where.not(api_access_token: nil)
  end

end
