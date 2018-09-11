module ImportAttributesHelper

  def import_attribute_tag(import_attribute)
    return nil if import_attribute.nil?
    '<b>' + import_attribute&.import_predicate.to_s + ':</b> ' + import_attribute&.value.to_s
  end

end
