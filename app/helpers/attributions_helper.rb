module AttributionsHelper

  def attribution_tag(attribution)
    return nil if attribution.nil?
    a = [
      attribution_copyright_tag(attribution),
      attribution_creators_tag(attribution),
      attribution_editors_tag(attribution),
      attribution_owners_tag(attribution),
      attribution.license,
    ]

    a.compact.join('. ').html_safe
  end

  # @return [String, nil]
  #   no html in _label
  # !! if _tag labels add HTML then they must be removed here
  def label_for_attribution(attribution)
    return nil if attribution.nil?

    a = [
      attribution_copyright_label(attribution),
      attribution_creators_tag(attribution),
      attribution_editors_tag(attribution),
      attribution_owners_tag(attribution),
      attribution.license,
    ]

    a.compact.join('. ').html_safe
  end

  # @return [String, nil]
  def attribution_copyright_label(attribution)
    a = attribution.copyright_year
    b = attribution.attribution_copyright_holders
    return nil unless a or b.any?
    s = '(c)'
    s << [a, Utilities::Strings.authorship_sentence(b.collect{|c| c.name})].join(' ')
    s
  end

  def attribution_copyright_tag(attribution)
    a = attribution.copyright_year
    b = attribution.attribution_copyright_holders
    return nil unless a or b.any?
    s = '&#169;'
    s << [a, Utilities::Strings.authorship_sentence(b.collect{|c| c.name})].join(' ')
    s.html_safe
  end

  def attribution_creators_tag(attribution)
    a = attribution.attribution_creators
    return nil unless a.any?
    ('Created by ' + Utilities::Strings.authorship_sentence(a.collect{|b| b.name})).html_safe
  end

  def attribution_editors_tag(attribution)
    a = attribution.attribution_editors
    return nil unless a.any?
    ('Edited by ' + Utilities::Strings.authorship_sentence(a.collect{|b| b.name})).html_safe
  end

  def attribution_owners_tag(attribution)
    a = attribution.attribution_owners
    return nil unless a.any?
    ('Owned by ' + Utilities::Strings.authorship_sentence(a.collect{|b| b.name})).html_safe
  end

  # @return [String (html), nil]
  #   a ul/li of tags for the object
  def attribution_list_tag(object)
    return nil unless object.has_attribution? && object.attribution
    content_tag(:h3, 'Attribution') +
      attribution_tag(object.attribution)
  end

end
