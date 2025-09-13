# Helpers to transition a unification towards feedback look and feel
module Workbench::FeedbackHelper

  def feedback_tag(content, type = :notice, thin = false)
    c = [:feedback, "feedback-#{type}"]
    c.push 'feedback-thin' if thin
    tag.div(content, class: c)
  end

  def warning_tag(content)
    tag.span(content, data: {icon: :warning})
  end
  
end
  
  
