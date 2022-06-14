class Tasks::Content::PublisherController < ApplicationController
  include TaskControllerConfiguration

  def index
  end

  def summary
  end
  
  def topic_table
    params.require(:topic_id)
  end

  def publish_all
    params.require(:topic_id)
    begin
      Content.transaction do
        Content.where(topic_id: params[:topic_id], project_is: sessions_current_project_id).each do |c|
          c.publish
        end
      end
      render 'topic_table'
    rescue ActiveRecord::RecordInvalid => e
    end
  end

  def unpublish_all
    params.require(:topic_id)
    begin
      Content.transaction do
        Content.where(topic_id: params[:topic_id], project_is: sessions_current_project_id).each do |c|
          c.unpublish
        end
      end
      render 'topic_table'
    rescue ActiveRecord::RecordInvalid => e
    end
  end



end
