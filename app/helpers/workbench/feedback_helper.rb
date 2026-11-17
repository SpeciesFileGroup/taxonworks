# Helpers to transition a unification towards feedback look and feel
module Workbench::FeedbackHelper

  def feedback_tag(content, type = :notice, thin = false)
    c = [:feedback, "feedback-#{type}"]
    c.push 'feedback-thin' if thin
    tag.div(content, class: c)
  end

  # An inline badge, e.g. a status or rank beside a name.
  # @param type [Symbol, String] the feedback modifier, e.g. :warning, :light
  # @return [ActiveSupport::SafeBuffer] content escaped
  def feedback_badge_tag(content, type = :info)
    tag.span(content, class: [:feedback, 'feedback-thin', "feedback-#{type}"])
  end

  def warning_tag(content)
    tag.span(content, data: {icon: :warning})
  end
  
end
  
  
