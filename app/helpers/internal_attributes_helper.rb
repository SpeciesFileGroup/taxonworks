module InternalAttributesHelper

  def internal_attribute_tag(internal_attribute)
    return nil if internal_attribute.nil?
    '<b>' + internal_attribute.predicate.name + ':</b> ' + internal_attribute.value
  end

end
