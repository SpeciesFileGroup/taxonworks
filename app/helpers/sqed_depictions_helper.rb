require 'waxy'

module SqedDepictionsHelper

  def sqed_depiction_tag(sqed_depiction)
    return nil if sqed_depiction.nil?
    image_tag(sqed_depiction.depiction.image.image_file.url(:thumb)) + ' on ' + object_tag(sqed_depiction.depiction.depiction_object.metamorphosize)
  end

  def sqed_depiction_link(sqed_depiction)
    return nil if sqed_depiction.nil?
    link_to(sqed_depiction_tag(sqed_depiction), sqed_depiction.depiction)
  end

  def sqed_depiction_collecting_event_label_thumb_preview(sqed_depiction)
    return content_tag(:div, 'no depiction provided', class: :warning) if sqed_depiction.nil?
    section = sqed_depiction.collecting_event_sections.first
    return content_tag(:div, 'no collecting event label data imaged', class: :warning) if section.nil?

    begin
      result = SqedToTaxonworks::Result.new(
        depiction_id: sqed_depiction.depiction.id,
      )

     return image_tag(result.image_path_for_large_image(section), id: 'little1', class: 'little_image clickable') 
    rescue
      return content_tag(:div, link_to('Error parsing.', depiction_path(sqed_depiction.depiction)), class: :warning) 
    end
  end

  def sqed_depiction_thumb_navigator(sqed_depiction, before = 3, after = 3)
    around = sqed_depiction.nearby_sqed_depictions(before, after)
    
    around[:before].reverse.collect{|s| 
      link_to(sqed_depiction_collecting_event_label_thumb_preview(s), collection_object_buffered_data_breakdown_task_path(s.depiction.depiction_object))  
    }.join().html_safe +
    
    content_tag(:div, ' this record ', class: 'sqed_thumb_nav_current') +
   
    around[:after].collect{|s| 
      link_to(sqed_depiction_collecting_event_label_thumb_preview(s), collection_object_buffered_data_breakdown_task_path(s.depiction.depiction_object), 'data-turbolinks' => 'false')  
    }.join().html_safe 
  end

  def sqed_done_tag(project_id)
    SqedDepiction.where(project_id: project_id).count - SqedDepiction.without_collection_object_data.where(project_id: project_id).count
  end

  def sqed_not_done_tag(project_id)
    SqedDepiction.without_collection_object_data.where(project_id: project_id).count
  end
  
  def sqed_previous_next_links(sqed_depiction)
    around = sqed_depiction.nearby_sqed_depictions(1, 1)
    a = content_tag(:li, link_to('Previous', sqed_depiction_breakdown_task_path(around[:before].first), 'data-turbolinks' => 'false') ) if around[:before].any?
    b = content_tag(:li, link_to('Next', sqed_depiction_breakdown_task_path(around[:after].first), 'data-turbolinks' => 'false')) if around[:after].any?
    [a,b].compact.join.html_safe
  end

  def sqed_last_with_data_tag
    if o = SqedDepiction.with_collection_object_data.where(project_id: sessions_current_project_id).last
      content_tag(:span, ('Last with data: ' + sqed_card_link(o)).html_safe, class: [:feedback, 'feedback-success', 'feedback-thin'])
    else
      nil
    end
  end

  def sqed_last_without_data_tag
    if o = SqedDepiction.where(project_id: sessions_current_project_id).without_collection_object_data.last
      content_tag(:span, ('Last without data: ' + sqed_card_link(o)).html_safe, class: [:feedback, 'feedback-warning', 'feedback-thin'])
    else
      nil
    end
  end

  def sqed_first_without_data_tag
    if o = SqedDepiction.where(project_id: sessions_current_project_id).without_collection_object_data.first
      content_tag(:span, ('First without data: ' + sqed_card_link(o)).html_safe, class: [:feedback, 'feedback-warning', 'feedback-thin'])
    else
      nil
    end
  end
  
  def sqed_first_with_data_tag
    if o = SqedDepiction.where(project_id: sessions_current_project_id).with_collection_object_data.first
      content_tag(:span, ('First with data: ' + sqed_card_link(o)).html_safe, class: [:feedback, 'feedback-success', 'feedback-thin'])
    else
      nil
    end
  end

  def sqed_last_by_user_tag
    if o = SqedDepiction.joins(:collection_object)
      .where(
        project_id: sessions_current_project_id,
        updated_by_id: sessions_current_user_id)
      .with_collection_object_data
      .order('collection_objects.updated_at')
      .first
      content_tag(:span, ('Last update by you: ' + sqed_card_link(o)).html_safe, class: [:feedback, 'feedback-success', 'feedback-thin'])
    else
      nil
    end
  end

  def sqed_card_link(sqed_depiction)
    link_to(sqed_depiction.id, sqed_depiction_breakdown_task_path(sqed_depiction), 'data-turbolinks' => 'false') 
  end

  def sqed_waxy_layout(sqed_depictions)
    layout = Waxy::Geometry::Layout.new(
      Waxy::Geometry::Orientation::LAYOUT_POINTY,
      Waxy::Geometry::Point.new(20,20), # size
      Waxy::Geometry::Point.new(20,20), # start
      9 # padding
    ) 

    meta = []

    sqed_depictions.each do |i|
      a = Waxy::Meta.new
      a.size = sqed_waxy_metadata(i)
      a.stroke = i.in_progress? ? 'purple' : 'grey'
      a.link = i.in_progress? && !(i.updated_by_id == sessions_current_user_id) ? nil : sqed_depiction_breakdown_task_path(i).html_safe
      a.link_title = "#{i.id.to_s} created #{time_ago_in_words(i.created_at)} ago by #{user_tag(i.creator)}"
      meta.unshift a
    end

    c = Waxy::Render::Svg::Canvas.new(600, 400)
    c.body << Waxy::Render::Svg.rectangle(layout, meta, 9)
    c.to_svg.html_safe
  end

  # @return Array lenght 6
  def sqed_waxy_metadata(sqed_depiction)
    o = sqed_depiction.depiction_object
    [
      (o.identifiers.any? ? 1 : 0),
      (o.buffered_collecting_event.blank? ? 0 : 1),
      (o.buffered_determinations.blank? ? 0 : 1),
      (o.buffered_other_labels.blank? ? 0 : 1),
      (o.collecting_event_id ? 1 : 0),
      (o.taxon_determinations.any? ? 1 : 0)
    ]
  end

  def sqed_waxy_legend_section_tag(position, label)
    layout = Waxy::Geometry::Layout.new(
      Waxy::Geometry::Orientation::LAYOUT_POINTY,
      Waxy::Geometry::Point.new(15,15), # size
      Waxy::Geometry::Point.new(15,15), # start
    )

    a = Waxy::Meta.new
    a.stroke = 'grey'
    a.size = (0..5).collect{|s| position == s ? 1.0 : 0 }
    meta = [a]

    c = Waxy::Render::Svg::Canvas.new(35, 35)
    c.body << Waxy::Render::Svg.rectangle(layout, meta)

    content_tag(:figure) do
      c.to_svg.html_safe +
        content_tag(:figcaption, label)
    end
  end

  def sqed_waxy_legend_tag
    l = ''
    {
      0 => 'Identifier(s)',
      1 => 'Buffered collecting event',
      2 => 'Buffered determination',
      3 => 'Buffered other labels',
      4 => 'Collecting event',
      5 => 'Taxon determination(s)'
    }.each do |i,label|
      l << sqed_waxy_legend_section_tag(i, label)
    end
    content_tag(:div) do
      content_tag(:h3, 'Legend') +
        content_tag(:p, content_tag(:em, 'Triangle indicates data presence')) +
        content_tag(:div, l.html_safe)
    end
  end

end
