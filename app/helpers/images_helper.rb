module ImagesHelper

  # !! Rails already provides image_tag, i.e. it is not required here.

  def image_link(image)
    return nil if image.nil?
    link_to(image_tag(image).html_safe, image)
  end

  def images_search_form
    render('/images/quick_search_form')
  end

end
