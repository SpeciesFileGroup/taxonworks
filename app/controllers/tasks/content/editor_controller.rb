class Tasks::Content::EditorController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
  end

  # GET .json
  def recent_topics
    @controlled_vocabulary_terms = Topic.where(project: sessions_current_project).distinct.recently_updated.limit(range_limit(params[:limit])).order(:name)
    render '/controlled_vocabulary_terms/index'
  end

  # GET .json
  def recent_otus
    @otus = Otu.where(project: sessions_current_project).distinct.recently_updated.limit(range_limit(params[:limit]))
    render '/otus/index'
  end

  def range_limit(param = default,min = 1,max = 30,default = 5)
    if (param.to_i.between? min, max)
      return param
    else
      param = default
    end     
  end

end
