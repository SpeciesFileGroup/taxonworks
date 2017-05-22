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


  def loan_status_tag(object)
    if object.is_loanable? && object.has_been_loaned?
      content_tag(:h3, 'Loan status') + 
        content_tag(:ul) do
        (on_loan_tag(object) +
         loan_history_tag(object)).html_safe
      end
    end
  end

  def loan_history_tag(object)
    content_tag(:li, "Loaned #{object.times_loaned} times.")
  end

  def on_loan_tag(object)
    if object.is_loanable? && object.on_loan?
      content_tag(:li) do
        'On ' + 
          link_to('loan', object.loan) + '.' +
          "Due back on #{object.loan_return_date}, #{overdue_tag(object.loan)}."
      end
    else
      ''
    end
  end

  def overdue_tag(loan)
    if loan.overdue?
      "#{loan.days_overdue} days overdue."
    else
      "#{loan.days_until_due} days until due."  
    end
  end

end
