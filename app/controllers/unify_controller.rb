class UnifyController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_targets, only: [:unify]

  def unify
    r = @keep_object.unify(@remove_object, only: params[:only], except: params[:except], preview: params[:preview])
    render json: r
  end

  # TO preview relationships
  # GET /merge/relations?klass=Otu
  def relations
    # something params[:klass]  
  end

  private

  def set_targets
    @remove_object = GlobalID::Locator.locate(params.require(:remove_global_id))
    @keep_objecct = GlobalID::Locator.locate(params.require(:keep_global_id))
  end
  
end
