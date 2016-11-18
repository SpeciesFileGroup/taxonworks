module Workbench::SoftValidationHelper

  def soft_validation_alert_tag(object)
  #object.soft_validate
  #content_tag(:span, '', 
  #            data: { icon: 'attention'},
  #            title: object.soft_validations.soft_validations.collect{|m| m.message}.join('; ') 
  #           ) if !object.soft_valid?
  end

end
