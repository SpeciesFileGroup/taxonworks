module InternalAttributesHelper

  def internal_attribute_tag(internal_attribute)
    return nil if internal_attribute.nil?
    name = internal_attribute.predicate&.name
    "<b>#{name.present? ? name : ''}:</b>#{internal_attribute.value}"
  end

end
