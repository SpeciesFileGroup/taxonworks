module SqedDepictionsHelper

  def sqed_depiction_tag(sqed_depiction)
    return nil if sqed_depiction.nil?
    image_tag(sqed_depiction.depiction.image.image_file.url(:thumb)) + " on " + object_tag(sqed_depiction.depiction.depiction_object.metamorphosize)
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

     return image_tag(result.image_path_for_large_image(section), id: "little1", class: "little_image clickable") 
    rescue
     return content_tag(:div, link_to('Error parsing.', depiction_path(sqed_depiction.depiction)), class: :warning) 
    end
  end

  def sqed_depiction_thumb_navigator(sqed_depiction, before = 3, after = 3)
    around = sqed_depiction.nearby_sqed_depictions(before, after)
    
    around[:before].reverse.collect{|s| 
      link_to(sqed_depiction_collecting_event_label_thumb_preview(s), collection_object_buffered_data_breakdown_task_path(s.depiction.depiction_object))  
    }.join().html_safe +
    
    content_tag(:div, " this record ", class: 'sqed_thumb_nav_current') +
   
    around[:after].collect{|s| 
      link_to(sqed_depiction_collecting_event_label_thumb_preview(s), collection_object_buffered_data_breakdown_task_path(s.depiction.depiction_object), 'data-no-turbolink' => 'true')  
    }.join().html_safe 
  end

  def sqed_done_tag(project_id)
    SqedDepiction.where(project_id: project_id).count - SqedDepiction.without_collection_object_data.where(project_id: project_id).count
  end

  def sqed_not_done_tag(project_id)
    SqedDepiction.where(project_id: project_id).without_collection_object_data.count
  end




end
