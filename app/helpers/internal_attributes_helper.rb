module InternalAttributesHelper

  def internal_attribute_tag(internal_attribute)
    return nil if internal_attribute.nil?
    internal_attribute.predicate.name + ": " + internal_attribute.value 
  end

end
