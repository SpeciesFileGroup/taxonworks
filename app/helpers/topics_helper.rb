module TopicsHelper

  def topic_tag(topic)
    return nil if topic.nil?
    topic.name
  end

  def topics_search_form
    render('/topics/quick_search_form')
  end

end
