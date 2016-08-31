module LoansHelper

  def loan_tag(loan)
    return nil if loan.nil?
    [loan.id, loan.people.collect{|a| a.name}.join(', '), loan.recipient_address].delete_if{|b| b.blank? }.join(" - ").gsub(/\n/, '; ') 
  end

  def loan_link(loan)
    return nil if loan.nil?
    link_to(loan_tag(loan).html_safe, loan)
  end

  def loans_search_form
    render('/loans/quick_search_form')
  end

end
