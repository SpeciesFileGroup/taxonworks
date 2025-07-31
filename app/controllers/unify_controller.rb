class UnifyController < ApplicationController
  before_action :require_sign_in_and_project_selection
  before_action :set_targets, only: [:unify]

  def unify
    r = @keep_object.unify(
      @remove_object,
      only: params[:only] || [],
      except: params[:except] || [],
      preview: params[:preview],
      target_project_id: sessions_current_project_id
    )
    render json: r
  end

  # TO preview relationships
  # GET /merge/relations?klass=Otu
  def relations
    # something params[:klass]  
  end

  # GET /unify/metadata
  def metadata
    object = GlobalID::Locator.locate(params.require(:global_id))
    render json: object.unify_relations_metadata(target_project_id: sessions_current_project_id)
  end

  private

  def set_targets
    @remove_object = GlobalID::Locator.locate(params.require(:remove_global_id))
    @keep_object = GlobalID::Locator.locate(params.require(:keep_global_id))
  end
  
end
