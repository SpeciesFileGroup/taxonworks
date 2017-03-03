class Tasks::Content::EditorController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
  end

  # GET .json
  def recent_topics
    @controlled_vocabulary_terms = Topic.where(project: sessions_current_project).distinct.recently_updated(5).order(:name)
    render '/controlled_vocabulary_terms/index'
  end

  # GET .json
  def recent_otus
    @otus = Otu.where(project: sessions_current_project).distinct.recently_updated(5)
    render '/otus/index'
  end

end
