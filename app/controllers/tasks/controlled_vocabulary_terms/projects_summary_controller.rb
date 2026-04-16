class Tasks::ControlledVocabularyTerms::ProjectsSummaryController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
  end

  def switch_projects
    # switch projects
    sessions_sign_in(user, request)
 
    redirect_to :manage_controlled_vocabulary_terms_task_path
  end

end
