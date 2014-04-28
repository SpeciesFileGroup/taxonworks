module ApplicationHelper


  def scrollable_div_tag(text)
    content_tag(:div, text, class: :scollable_div)
  end

end
