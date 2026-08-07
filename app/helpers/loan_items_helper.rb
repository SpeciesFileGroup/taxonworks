module LoanItemsHelper

  def loan_item_tag(loan_item)
    return nil if loan_item.nil?
    [
      object_tag(loan_item.loan_item_object),
      "[#{loan_item_total_string(loan_item)} total]",
      (loan_item.returned? ? "returned #{loan_item.date_returned}" : nil),
      (loan_item.disposition.blank? ? nil : content_tag(:span, loan_item.disposition, class: :warning)),
      "(#{loan_item.loan_item_object_type})"
    ].compact.join('&nbsp;').html_safe
  end

  def loan_item_link(loan_item)
    return nil if loan_item.nil?
    link_to(loan_item_tag(loan_item), loan_item) # metamorphosize_if(loan_item.loan_item_object))
  end

  #  def loan_items_search_form
  #    render('/loan_items/quick_search_form')
  #  end

  def loan_item_total_string(loan_item)
    if t = loan_item.total_items
      t
    else
      'undefined'
    end
  end

  def loan_item_type_status(loan_item)
    case loan_item.loan_item_object_type
    when 'CollectionObject'
      loan_item.loan_item_object.type_materials.pluck(:type_type).join('; ').presence
    when 'Container'
      l = [ ]
      loan_item.loan_item_object.all_collection_object_ids.each do |o|
        if t = CollectionObject.find(o).type_materials.load
          l.push t.pluck(:type_type)
        end
      end
      l.flatten.compact.uniq.join('; ').presence
    else
      nil
    end
  end

end

