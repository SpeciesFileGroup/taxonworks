
# Helpers that add/wrap information in CSS/SCSS, or are related
# to adding attributes to CSS.  Also includes 'data-' related functionality.
module Workbench::StyleHelper

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

  def toggle_class_css(css_class, boolean)
    if boolean
      css_class
    else
      nil
    end
  end

  # Wrap content in a span, and give it a :data class
  # @return [String]
  def data_tag(content)
    content_tag(:span, content, class: :data)
  end

  def attribute_tag(label, content)
    content_tag(:p) do
      content_tag(:strong, label) + ' ' +
        data_tag(content)
    end
  end

  def attribute_block(hash)
    hash.collect{|label, content| attribute_tag(label, content)}.join.html_safe
  end

  # TODO: make the color an attribute and apply it after, give a border
  def color_tag(css_color = nil, value)
    return value if css_color.nil?
    content_tag(:span, value, style: "background-color: #{css_color};")
  end

end
