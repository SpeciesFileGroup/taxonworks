class Api::V1::BaseController < ApiController 

  def index
    render(json: {success: true}, status: 200)
  end

end
