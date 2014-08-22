module LoansHelper

  def self.loan_tag(loan)
    return nil if loan.nil?
    loan.recipient_email
  end

  def loan_tag(loan)
    LoansHelper.loan_tag(loan)
  end

  def loan_link(loan)
    return nil if loan.nil?
    link_to(LoansHelper.loan_tag(loan).html_safe, loan)
  end

  def loans_search_form
    render('/loans/quick_search_form')
  end

end
