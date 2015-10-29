module LoanItemsHelper

  def loan_item_tag(loan_item)
    return nil if loan_item.nil?
    [loan_item.position, object_tag(loan_item.loan_item_object)].join(": ")
  end

  def loan_item_link(loan_item)
    return nil if loan_item.nil?
    link_to(loan_item_tag(loan_item).html_safe, metamorphosize_if(loan_item.loan_item_object))
  end

  def loan_items_search_form
    render('/loan_items/quick_search_form')
  end

end

