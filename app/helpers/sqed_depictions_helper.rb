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

  def sqed_last_with_data_tag(project_id)
    if o = SqedDepiction.with_collection_object_data.where(project_id: project_id).last
      content_tag(:span, ('Last with data: ' + sqed_card_link(o)).html_safe, class: [:feedback, 'feedback-success'])
    else
      nil
    end
  end

  def sqed_last_without_data_tag(project_id)
    if o = SqedDepiction.without_collection_object_data.where(project_id: sessions_current_project_id).last
      content_tag(:span, ('Last without data: ' + sqed_card_link(o)).html_safe, class: [:feedback, 'feedback-warning'])
    else
      nil
    end
  end

  def sqed_first_without_data_tag(project_id)
    if o = SqedDepiction.without_collection_object_data.where(project_id: sessions_current_project_id).first
      content_tag(:span, ('First without data: ' + sqed_card_link(o)).html_safe, class: [:feedback, 'feedback-warning'])
    else
      nil
    end
  end
  
  def sqed_first_with_data_tag(project_id)
    if o = SqedDepiction.with_collection_object_data.where(project_id: sessions_current_project_id).first
      content_tag(:span, ('First with data: ' + sqed_card_link(o)).html_safe, class: [:feedback, 'feedback-success'])
    else
      nil
    end
  end

  def sqed_card_link(sqed_depiction)
    link_to(sqed_depiction.id, sqed_depiction_breakdown_task_path(sqed_depiction), 'data-turbolinks' => 'false') 
  end

  def waxy_layout(sqed_depictions)
    layout = Waxy::Geometry::Layout.new(
      Waxy::Geometry::Orientation::LAYOUT_POINTY,
      Waxy::Geometry::Point.new(20,20), # size
      Waxy::Geometry::Point.new(20,20), # start
    ) 

    meta = []

    sqed_depictions.each do |i|
      a = Waxy::Meta.new
      a.size = (0..5).collect{ rand(0.0..1.0) } 
      a.stroke = 'grey'
      a.link = sqed_card_link(i)
      meta.push a 
    end

    meta.sort!{ |a,b| a.sum_size <=> b.sum_size }

    c = Waxy::Render::Svg::Canvas.new(1000, 1000)
    c.body << Waxy::Render::Svg.rectangle(layout, meta)
    c.to_svg.html_safe
  end

end
