module LoansHelper

  def loan_tag(loan)
    return nil if loan.nil?
    [
      content_tag(:span, (identifier_tag(loan_identifier(loan)) || loan.id), class: [:feedback, 'feedback-thin', 'feedback-primary']),
      loan.loan_recipients.collect{|a| a.name}.join(', '),
      loan.recipient_email,
      loan.date_sent,
      loan.recipient_address].delete_if{|b| b.blank? }.join(' - ').gsub(/\n/, '; ').html_safe
  end

  def label_for_loan(loan)
    s = "loan #{loan.id}"
    s << loan.identifiers&.pluck(:cached)&.join(', ')
  end

  def loan_recipients_tag(loan)
    return nil if loan.nil?
    recipients = loan.loan_recipients.collect{|lr| person_tag(lr)}.join.html_safe
    recipients.blank? ? 'No recipients defined!' : recipients
  end

  def loan_autocomplete_tag(loan)
    return nil if loan.nil?
    [
      content_tag(:span, (identifier_tag(loan_identifier(loan)) || loan.id), class: [:feedback, 'feedback-thin', 'feedback-primary']),
      loan.loan_recipients.collect{|a| a.name}.join(', '),
      loan.recipient_email,
      loan.date_sent,
      loan.recipient_address,
      loan_status_tag(loan)
    ].delete_if{|b| b.blank? }.join(' - ').gsub(/\n/, '; ').html_safe
  end

  def loan_identifier(loan)
    loan.identifiers.where(type: 'Identifier::Local::LoanCode').first
  end

  def loan_status_tag(loan)
    return nil if loan.nil?
    return tag.span('Returned/canceled', class: [:feedback, 'feedback-thin', 'feedback-success']) if loan.date_closed.present?
    if loan.date_return_expected.present?
      return tag.span("Due in #{distance_of_time_in_words_to_now(loan.date_return_expected)}", class: [:feedback, 'feedback-thin', 'feedback-information']) if loan.date_return_expected > Time.now
      return tag.span("#{distance_of_time_in_words(loan.date_return_expected)} overdue", class: [:feedback, 'feedback-thin', 'feedback-danger']) if loan.date_return_expected < Time.now
    end
    return tag.span("Lost/destroyed", class: [:feedback, 'feedback-thin', 'feedback-warning']) if loan.loan_items.count == loan.loan_items.where(disposition: ['Lost', 'Destroyed']).distinct.count
  end

  def loan_link(loan)
    return nil if loan.nil?
    link_to(loan_tag(loan).html_safe, loan)
  end

  def loans_search_form
    render('/loans/quick_search_form')
  end

  def object_loan_status_tag(object)
    if object.has_loans? && object.has_been_loaned?
      content_tag(:h3, 'Loan status') +
        content_tag(:ul) do
          (on_loan_tag(object) +
           object_loan_history_tag(object)).html_safe
        end
    end
  end

  def object_loan_history_tag(object)
    content_tag(:li, "Loaned #{object.times_loaned} times.")
  end

  def on_loan_tag(object)
    if object.has_loans? && object.on_loan?
      content_tag(:li) do
        ['On ' +  link_to('loan', object.loan) + '.',
         loan_overdue_tag(object.loan),
         loan_due_back_tag(object.loan)
        ].join(' ').html_safe
      end
    else
      ''
    end
  end

  def loan_overdue_tag(loan)
    if loan.date_return_expected.present?
      if loan.overdue?
        "#{loan.days_overdue} days overdue."
      else
        "#{loan.days_until_due} days until due."
      end
    else
      content_tag(:span, 'Due date NOT PROVIDED.', data: {icon: :warning})
    end

  end

  def loan_due_back_tag(loan)
    'Due back on ' +
      ( loan.date_return_expected.present? ? loan.date_return_expected.to_s : 'NOT PROVIDED' ) +
      '.'
  end

  def keywords_on_loanable_items
    Keyword.joins(:tags).where(project_id: sessions_current_project_id).where(tags: {tag_object_type: ['Container', 'Otu', 'CollectionObject']}).distinct.all
  end

end
