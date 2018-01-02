module PreparationTypesHelper

  def preparation_type_tag(preparation_type)
    return nil if preparation_type.nil?
    preparation_type.name
  end

  def preparation_type_link(preparation_type)
    return nil if preparation_type.nil?
    link_to(preparation_type_tag(preparation_type).html_safe, preparation_type)
  end

  def preparation_types_search_form
    render('/preparation_types/quick_search_form')
  end

  def preparation_types_select(selected: nil, preparation_types: PreparationType.all.to_a)
    select_tag('preparation_type[id]' , options_from_collection_for_select(preparation_types, :id, :name, selected.try(:id)), include_blank: true)
  end

end
