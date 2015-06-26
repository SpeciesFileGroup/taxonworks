module ImagesHelper

  # !! Rails already provides image_tag, i.e. it is not required here.

  def image_link(image)
    return nil if image.nil?
    link_to(image_tag(image).html_safe, image)
  end

  def images_search_form
    render('/images/quick_search_form')
  end

  # @return [True]
  #   indicates a custom partial should be used, see list_helper.rb
  def images_recent_objects_partial
    true 
  end

end
