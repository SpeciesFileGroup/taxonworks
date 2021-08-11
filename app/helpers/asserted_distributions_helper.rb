module AssertedDistributionsHelper

  def asserted_distribution_tag(asserted_distribution)
    return nil if asserted_distribution.nil?
    [
      otu_tag(asserted_distribution.otu),
      (asserted_distribution.is_absent ? content_tag(:span,
                                                     ' not in ',
                                                     class: :warning) : ' in '),
      geographic_area_tag(asserted_distribution.geographic_area) #,
    # ' by ',
    # (asserted_distribution.source.cached_author_string ? asserted_distribution.source.cached_author_string
    # : content_tag(:span, '[source authors must be updated]', class: :warning))
    ].join('&nbsp;')
  end

  def asserted_distribution_link(asserted_distribution)
    return nil if asserted_distribution.nil?
    [
      link_to(otu_tag(asserted_distribution.otu).html_safe, asserted_distribution.otu),
      (asserted_distribution.is_absent ? content_tag(:span,
                                                     ' not in ',
                                                     class: :warning) : ' in '),
      link_to(geographic_area_tag(asserted_distribution.geographic_area).html_safe, asserted_distribution)
    ].join('&nbsp;')
    #link_to(asserted_distribution_tag(asserted_distribution).html_safe, asserted_distribution)
  end

  def asserted_distributions_search_form
    render('/asserted_distributions/quick_search_form')
  end

  def no_geographic_items?
    ' (has no geographic items)' if @asserted_distribution.geographic_area.geographic_items.empty?
  end

end
