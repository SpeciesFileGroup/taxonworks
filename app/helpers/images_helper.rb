module ImagesHelper

  def self.image_tag(image)
    return nil if image.nil?
    image.to_param
  end

  def image_tag(image)
    ImagesHelper.image_tag(image)
  end

  def image_link(image)
    return nil if image.nil?
    link_to(image_tag(image).html_safe, image)
  end

  def images_search_form
    render('/images/quick_search_form')
  end

end
