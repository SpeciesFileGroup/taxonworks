module ImportAttributesHelper

  def import_attribute_tag(import_attribute)
    return nil if import_attribute.nil?
    import_attribute.import_predicate + ": " + import_attribute.value 
  end

end
