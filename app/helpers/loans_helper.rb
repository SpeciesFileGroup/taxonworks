module LoansHelper

  def self.loan_tag(loan)
    return nil if loan.nil?
    v = loan.recipient_email
    v.blank? ? "[#{loan.to_param}]" : v
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
