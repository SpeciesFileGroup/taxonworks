module ExtractsHelper

  # TODO: reference identifiers/origin objects etc.
  def extract_tag(extract)
    return nil if extract.nil?
    e = []

    if extract.old_objects.any?
      e.push ' from: '
      e.push extract.old_objects.collect{|o| object_link(o) }
    else
      "#{extract.id} (no origin)"
    end

    e.push "Extract " + extract.id.to_s if e.empty?

    e.join.html_safe
  end

  def extract_link(extract)
    return nil if extract.nil?
    link_to(extract_tag(extract), extract)
  end

  def label_for_extract(extract)
    return nil if extract.nil?
    [ extract_origin_labels(extract),
    #  extract_otu_labels(extract),
      extract_made_tag(extract),
      identifier_list_labels(extract)
    ].compact.join('; ')
  end

  def extract_autocomplete_tag(extract)
    return nil if extract.nil?
    [simple_identifier_list_tag(extract),
     extract_origin_tags(extract),
    ].join(' ').html_safe
  end

  # @return [String, nil\
  #   no HTML
  def extract_made_tag(extract)
    [extract.year_made,
     extract.month_made,
     extract.day_made].compact.join('-')
  end

  def extract_otu_labels(extract)
    extract.referenced_otus.collect{|o| label_for_otu(o)}.join('; ')
  end

  def extract_origin_labels(extract)
   a = extract.old_objects.collect{|o| label_for(o)}
   a.unshift 'Origin' if !a.nil?
   a ? a.join(': ') + '.' : nil
  end

  def extract_origin_tags(extract)
   a = extract.old_objects.collect{|o| object_tag(o)}
   a.unshift 'Origin' if !a.nil?
   a ? a.join(': ') + '.' : nil
  end

  def extracts_search_form
    render('/extracts/quick_search_form')
  end

end
