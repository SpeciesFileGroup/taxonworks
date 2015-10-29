module LoanItemsHelper

  def loan_item_tag(loan_item)
    return nil if loan_item.nil?
    # @todo mjy Please fix next two lines
    # v = loan.recipient_email
    # v.blank? ? "[#{loan.to_param}]" : v
  end

  def loan_item_link(loan_item)
    return nil if loan_item.nil?
    link_to(loan_item_tag(loan_item).html_safe, loan_item)
  end

  def loan_items_search_form
    render('/loan_items/quick_search_form')
  end

end
