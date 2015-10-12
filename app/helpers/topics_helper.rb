module TopicsHelper

  def self.topic_tag(topic)
    return nil if topic.nil?
    topic.name
  end

  def topic_tag(topic)
    TopicsHelper.topic_tag(topic)
  end

  def topics_search_form
    render('/topics/quick_search_form')
  end

end
