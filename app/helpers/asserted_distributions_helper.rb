module AssertedDistributionsHelper

  def asserted_distribution_tag(asserted_distribution)
    return nil if asserted_distribution.nil?
    [
      asserted_distribution_object(asserted_distribution, true).html_safe,
      (asserted_distribution.is_absent ? tag.span(' not in ', class: [:feedback, 'feedback-thin', 'feedback-warning']).html_safe : ' in ').html_safe,
      asserted_distribution_geo(asserted_distribution, true).html_safe
    # ' by ',
    # (asserted_distribution.source.cached_author_string ? asserted_distribution.source.cached_author_string
    # : content_tag(:span, '[source authors must be updated]', class: :warning))
    ].join('&nbsp;').html_safe
  end

  def label_for_asserted_distribution(asserted_distribution)
    return nil if asserted_distribution.nil?
    [
      asserted_distribution_object(asserted_distribution, false),
      asserted_distribution_geo(asserted_distribution, false)
    ].compact.join(' in ')
  end

  def asserted_distribution_link(asserted_distribution)
    return nil if asserted_distribution.nil?
    [
      link_to(
        asserted_distribution_object(asserted_distribution, true).html_safe,
        asserted_distribution
      ),
      (asserted_distribution.is_absent ? content_tag(:span, ' not in ', class: :warning) : ' in '
      ),
      link_to(
        asserted_distribution_geo(asserted_distribution, true).html_safe,
        asserted_distribution
      )
    ].join('&nbsp;').html_safe
  end

  def asserted_distribution_object(asserted_distribution, html)
    object = asserted_distribution.asserted_distribution_object.metamorphosize
    klass = object.class.name.underscore

    if html
      send("#{klass}_tag", object)
    else
      send("label_for_#{klass}", object)
    end
  end

  def asserted_distribution_geo(asserted_distribution, html)
    shape = asserted_distribution.asserted_distribution_shape
    if html
      [
        object_tag(shape),
        geo_flair(asserted_distribution, true)
      ].join('&nbsp;')
    else
      [
        label_for(shape),
        geo_flair(asserted_distribution, false)
      ].join(' ')
    end
  end

  def geo_flair(asserted_distribution, html)
    type = asserted_distribution.asserted_distribution_shape_type
    feedback_type =
      type == 'GeographicArea' ? 'feedback-primary' : 'feedback-secondary'

    if html
      content_tag(:span, type.titleize,
         class: [:feedback, feedback_type, 'feedback-thin'])
    else
      "[#{type.titleize}]"
    end
  end

  def asserted_distributions_search_form
    render('/asserted_distributions/quick_search_form')
  end

  def no_geographic_items?
    ' (has no geographic items)' if @asserted_distribution.asserted_distribution_shape.geographic_items.empty?
  end

  # @return [Hash] GeoJSON feature
  def asserted_distribution_to_geo_json_feature(asserted_distribution)
    return nil if asserted_distribution.nil?
    return nil unless asserted_distribution.has_shape?

    return {
      'type' => 'Feature',
      'geometry' => RGeo::GeoJSON.encode(asserted_distribution.geo_object), # TODO: optimize
      'properties' => {
        'base' => {
          'type' => 'AssertedDistribution',
          'id' => asserted_distribution.id,
          'label' => label_for_asserted_distribution(asserted_distribution) },
        'shape' => {
          'type' => asserted_distribution.asserted_distribution_shape_type,
          'id' => asserted_distribution.asserted_distribution_shape_id },
        'is_absent' => asserted_distribution.is_absent
      }
    }
  end

end
