module Workbench::SoftValidationHelper

  # Populated after page load events with a sweeper
  #   .soft_validation_anchor { display:none }
  # After page load
  #  Hit http://127.0.0.1:3000/soft_validations/validate?global_id=gid%3A%2F%2Ftaxon%2Dworks%2FTaxonNameRelationship%3A%3AIczn%3A%3AValidating%3A%3AUncertainPlacement%2F209410
  #  to get JSON back
  def soft_validation_alert_tag(object)
    content_tag(
      :span, '',
      id: object_id_string(object, 'soft_validation'), 'title' => 'Click to view validations',
      class: [:soft_validation_anchor],
      data: { icon: 'attention', global_id: URI.encode_www_form_component( object.to_global_id.to_s) }
    )
  end

  def object_id_string(object, prefix = nil)
    [prefix, "#{object.metamorphosize.class}_#{object.id}"].compact.join('_')
  end

end
