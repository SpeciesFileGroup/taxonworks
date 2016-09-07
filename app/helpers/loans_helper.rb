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

  def on_loan_tag(object)
    if object.is_loanable? && object.on_loan?
      content_tag(:h3, 'Loan status') + 
        content_tag(:p, ('On ' + link_to('loan', object.loan) + '. Due back on ' + object.loan_return_date.to_s + '.').html_safe)
    end
  end

end
