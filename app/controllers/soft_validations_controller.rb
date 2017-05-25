class SoftValidationsController < ApplicationController

  def validate
    object = GlobalID::Locator.locate(URI.decode(params[:global_id]))
    object.soft_validate 

    render json: {
      validations: object.soft_validations
    }
  
  end

end
