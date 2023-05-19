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
    (recipients.presence || 'No recipients defined!')
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
      return tag.span("#{distance_of_time_in_words(Time.now, loan.date_return_expected)} overdue", class: [:feedback, 'feedback-thin', 'feedback-danger']) if loan.date_return_expected < Time.now
    end
    return tag.span('Lost/destroyed', class: [:feedback, 'feedback-thin', 'feedback-warning']) if loan.loan_items.count == loan.loan_items.where(disposition: ['Lost', 'Destroyed']).distinct.count
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

  # date_loan_requested, date_recieved, date_return_expected, date_closed
  def loans_per_year(loans, target = :date_sent )
    s,e = loans_start_end_year(loans, target)
    return {} if s.nil? && e.nil?

    data = zeroed_loan_year_hash(s,e)

    loans.select(target).each do |l|
      if y = l.send(target)&.year
        data[y] += 1
      end
    end

    data
  end

  def loans_start_end_year(loans, target = :date_sent)
    s = loans.unscope(:select).select("min(#{target}) d").unscope(:order).all[0][:d]&.year
    e = loans.unscope(:select).select("max(#{target}) d").unscope(:order).all[0][:d]&.year

    return [] if s.nil? && e.nil?

    if s && e
    elsif s
      e = s
    else
      s = e
    end
    [s,e]
  end

  def loan_items_totals_per_year(loans)
    s,e = loans_start_end_year(loans, :date_sent)
    y = zeroed_loan_year_hash(s,e)
    data = [
      {name: 'Otus',
       data: y
      },
      {name: 'CollectionObjects',
       data: y.dup
      }
    ]

    q = selected_loan_items(loans)

    q.where(loan_item_object_type: 'Otu').joins(:loan).pluck(:date_sent, :total).each do |d, t|
      data.first[:data][d&.year] += t if t
    end

    q.where(loan_item_object_type: 'CollectionObject')
      .joins(:loan)
      .joins('JOIN collection_objects on collection_objects.id = loan_items.loan_item_object_id')
      .pluck(:date_sent, 'collection_objects.total' ).each do |d, t|
        data.last[:data][d&.year] += t if t
      end

    data
  end

  def loan_fulfillment_latency(loans)
    s,e = loans_start_end_year(loans, :date_requested)
    d = arrayed_loan_year_hash(s,e)

    loans.where.not(date_requested: nil).where.not(date_sent: nil).all.pluck(:date_requested, :date_sent).each do |req, sent|
      y = req.year
      d[y].push(sent.jd - req.jd)
    end

    data = {}

    d.each do |y, times|
      if times.any?
        data[y] = (times.sum.to_f / times.length.to_f).to_i
      else
        data[y] = nil
      end
    end

    data
  end

  def arrayed_loan_year_hash(start_year, end_year)
    return {} if start_year.blank? || end_year.blank?
    years = {}
    (start_year..end_year).to_a.each do |y|
      years[y] = []
    end
    years[nil] = []
    years
  end

  def zeroed_loan_year_hash(start_year, end_year)
    return {} if start_year.blank? || end_year.blank?
    years = {}
    (start_year..end_year).to_a.each do |y|
      years[y] = 0
    end
    years[nil] = 0
    years
  end

  def loans_loan_item_disposition(loans)
    data =  Hash.new(0)

    q = selected_loan_items(loans)

    dispositions = LoanItem.where(project_id: sessions_current_project_id).select('disposition').distinct.pluck(:disposition)

    dispositions.each do |d|
      data[d] = q.where(disposition: d).count
    end

    data['unknown'] = data[nil]
    data.delete(nil)

    data
  end

  def selected_loan_items(loans)
    s = 'WITH selected_loans AS (' + loans.all.to_sql + ') ' +
      ::LoanItem
      .joins('JOIN selected_loans as selected_loans1 on selected_loans1.id = loan_items.loan_id')
      .to_sql

    ::LoanItem.from('(' + s + ') as loan_items')
  end

  def loans_individuals(loans)
    data = {
      otus: 0,
      collection_objects: 0
    }

    q = selected_loan_items(loans)

    data[:otus] = q.where(loan_item_object_type: 'Otu').joins(:loan).sum(:total)

    data[:collection_objects] = q.where(loan_item_object_type: 'CollectionObject')
      .joins(:loan)
      .joins('JOIN collection_objects on collection_objects.id = loan_items.loan_item_object_id')
      .sum('collection_objects.total')
    data
  end

  def loans_summary(loans)
    start_year, end_year = loans_start_end_year(loans, target = :date_sent)

    tag.table do
      [ tag.tr( tag.td('Total')+ tag.td(loans.all.count) ),

        tag.tr( tag.td('Year start (date sent)')+ tag.td(start_year) ),
        tag.tr( tag.td('Year end (date sent)')+ tag.td(end_year) ),
        tag.tr( tag.td('Year span')+ tag.td( [end_year, start_year].compact.size == 1 ? (end_year - start_year) : 0) ),

        tag.tr( tag.td('Overdue') + tag.td( loans.overdue.count ) ),
        tag.tr( tag.td('Not overdue') + tag.td( loans.not_overdue.count) ),
      ].join.html_safe
    end
  end

  def loan_total_individuals(loan)
    total = 0
    q = LoanItem.where(loan:)
    from_otu = q.sum(:total)
    from_collection_object = CollectionObject.joins(:loan_items).where(loan_items: {loan:}).sum('collection_objects.total')
    from_otu + from_collection_object
  end

  def overdue_individuals(loans)
    data = {
      otus: 0,
      collection_objects: 0
    }

    q = selected_loan_items(loans).where.not(date_returned: nil)

    data[:otus] = q.where(loan_item_object_type: 'Otu').joins(:loan).sum(:total)

    data[:collection_objects] = q.where(loan_item_object_type: 'CollectionObject')
      .joins(:loan)
      .joins('JOIN collection_objects on collection_objects.id = loan_items.loan_item_object_id')
      .sum('collection_objects.total')
    data
  end

  def loans_loan_item_summary(loans)
    a = loans_individuals(loans)
    b = overdue_individuals(loans)

    tag.table do
      [ tag.tr( tag.td('Total')+ tag.td(loans.collect{|a| a.loan_items.count}.sum) ),
        tag.tr( tag.td('CollectionObject items') + tag.td(loans.collect{|a| a.loan_items.where(loan_item_object_type: 'CollectionObject').count}.sum ) ),
        tag.tr( tag.td('OTU items') + tag.td(loans.collect{|a| a.loan_items.where(loan_item_object_type: 'Otu').count}.sum ) ),
        tag.tr( tag.td('Individuals') + tag.td( a[:otus] + a[:collection_objects] ) ),
        tag.tr( tag.td('Unreturned individuals') + tag.td( b[:otus] + b[:collection_objects] ) ),

      ].join.html_safe
    end
  end

end
