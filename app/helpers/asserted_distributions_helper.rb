module AssertedDistributionsHelper

  def asserted_distribution_tag(asserted_distribution)
    return nil if asserted_distribution.nil?
    [
      otu_tag(asserted_distribution.otu).html_safe,
      (asserted_distribution.is_absent ? tag.span(' not in ', class: [:feedback, 'feedback-thin', 'feedback-warning']).html_safe : ' in ').html_safe,
      geographic_area_tag(asserted_distribution.geographic_area).html_safe
                                                                      #,
    # ' by ',
    # (asserted_distribution.source.cached_author_string ? asserted_distribution.source.cached_author_string
    # : content_tag(:span, '[source authors must be updated]', class: :warning))
    ].join('&nbsp;').html_safe
  end

  def label_for_asserted_distribution(asserted_distribution)
    return nil if asserted_distribution.nil?
    [ label_for_otu(asserted_distribution.otu),
      label_for_geographic_area(asserted_distribution.geographic_area),
      label_for_source(asserted_distribution.source)
    ].compact.join(' in ')
  end

  def asserted_distribution_link(asserted_distribution)
    return nil if asserted_distribution.nil?
    [
      link_to(otu_tag(asserted_distribution.otu).html_safe, asserted_distribution.otu),
      (asserted_distribution.is_absent ? content_tag(:span, ' not in ', class: :warning) : ' in '),
      link_to(geographic_area_tag(asserted_distribution.geographic_area).html_safe,
              asserted_distribution) ].join('&nbsp;').html_safe
  end

  def asserted_distributions_search_form
    render('/asserted_distributions/quick_search_form')
  end

  def no_geographic_items?
    ' (has no geographic items)' if @asserted_distribution.geographic_area.geographic_items.empty?
  end

  # @return [Hash] GeoJSON feature
  def asserted_distribution_to_geo_json_feature(asserted_distribution)
    return nil if asserted_distribution.nil?
    return nil unless asserted_distribution.has_shape?
    
    return {
      'type' => 'Feature',

      # TODO: optimize
      'geometry' => RGeo::GeoJSON.encode(asserted_distribution.geographic_area.geographic_items.first.geo_object),
      'properties' => {
        'from' => {
          'type' => 'AssertedDistribution',
          'id' => asserted_distribution.id },
          'label' => label_for_asserted_distribution(asserted_distribution) }
    }
  end

end
