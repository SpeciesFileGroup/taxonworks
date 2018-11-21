module RequestType
  extend ActiveSupport::Concern

  def json_request?
    request.format.json?
  end

end
