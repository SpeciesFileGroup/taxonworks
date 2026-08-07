module LoanRecipientsHelper

  def loan_recipient_tag(loan_recipient)
    return nil if loan_recipient.nil?
    person_tag(loan_recipient.person)
  end

  def loan_recipient_link(loan)
    link_to(loan_recipient_tag(loan).html_safe, loan)
  end

end
