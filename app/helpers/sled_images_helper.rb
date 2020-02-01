module SledImagesHelper


  def sled_image_tag(sled_image)
    return nil if sled_image.nil?
    content_tag(:span, "sled image: #{sled_image.id}")
  end

  def sled_image_link(sled_image)
    return nil if sled_image.nil?
    link_to(sled_image_tag(sled_image), grid_digitize_task_path(sled_image_id: sled_image.id))
  end

end
