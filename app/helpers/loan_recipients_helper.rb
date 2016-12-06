module LoanRecipientsHelper

  def loan_recipient_tag(loan)
    return nil if loan.nil?
    recipients = loan.loan_recipients.collect{|lr| person_tag(lr)}.join.html_safe
    recipients.blank? ? 'No recipients defined!' : recipients
  end

  def loan_recipient_link(loan)
    link_to(loan_recipient_tag(loan).html_safe, loan)
  end

end
