module LoansHelper

  def loan_tag(loan)
    return nil if loan.nil?
     
    v = [loan.id, *loan.people.collect{|a| a.name}.join(', '), loan.recipient_address].compact.join(" - ").gsub(/\n/, '; ') 
    v.blank? ? "[#{loan.to_param}]" : v
  end

  def loan_link(loan)
    return nil if loan.nil?
    link_to(loan_tag(loan).html_safe, loan)
  end

  def loans_search_form
    render('/loans/quick_search_form')
  end

end
