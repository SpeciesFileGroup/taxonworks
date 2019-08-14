class Api::V1::BaseController < ApiController 

  def index
    render status: 200
  end

  def not_found
    render json: '{"success": false, "message": "Invalid route"}', status: :not_found
  end
end
