
# Helpers that add/wrap information in CSS/SCSS, or are related
# to adding attributes to CSS.  Also includes 'data-' related functionality.
module StyleHelper

  def scrollable_div_tag(text)
    return nil if text.blank?
    content_tag(:div, text, class: 'scrollable_div one_third')
  end

  def hidden_css_property_if(tru)
    tru ? 'hidden'.html_safe : nil
  end

  def collapsed_css_property_if(tru)
    tru ? 'collapsed'.html_safe : nil
  end

  # Set @no_turbolinks in a before_action, then use the method in, say a layout.
  def turbolinks_off_tag
    'data-no-turbolink="true"'.html_safe if @no_turbolinks
  end

end
