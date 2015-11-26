module ImportAttributesHelper

  def import_attribute_tag(import_attribute)
    return nil if import_attribute.nil?
    '<b>' + import_attribute.import_predicate + ':</b> ' + import_attribute.value
  end

end
