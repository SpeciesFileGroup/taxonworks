class Tasks::Content::PublisherController < ApplicationController
  include TaskControllerConfiguration

  def index
  end

  def summary
  end
  
  def topic_table
    params.require(:topic_id)
  end

end
