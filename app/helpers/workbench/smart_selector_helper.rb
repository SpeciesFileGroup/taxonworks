module Workbench::SmartSelectorHelper
  def smart_selector(params)
    content_tag(:div, '', data: { 
      'smart-selector' => true,
      'smart-selector-model' => params[:model], 
      'smart-selector-target' => params[:target], 
      'smart-selector-klass' => params[:klass],
      'smart-selector-field-object' => params[:field_object],
      'smart-selector-field-property' => params[:field_property],
      'smart-selector-title' => params[:title],
      'smart-selector-current-object-id' => params[:current]&.id,
      'smart-selector-current-object-label' => label_for(params[:current])
    })
  end
end
