module LoanRecipientsHelper

  def loan_recipient_tag(loan_recipient)
    return nil if loan_recipient.nil?
    role_tag(loan_recipient)
  end

  def loan_recipient_link(loan_recipient)
    link_to(loan_recipient_tag(loan_recipient).html_safe, loan_recipient.role_object.metamorphosize)
  end

end
