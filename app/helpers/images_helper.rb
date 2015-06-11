module ImagesHelper

  # !! Rails already provides image_tag, i.e. it is not required here.

  def image_link(image)
    return nil if image.nil?
    link_to(image_tag(image).html_safe, image)
  end

  def images_search_form
    render('/images/quick_search_form')
  end


  # Clip the image with css clip.
  # image is a Image instance
  # <%= css_clip(image: @depiction.image, height: 200, width: 0, x: 5, y: 20)  -%>
  def css_clip(image: nil, size: :medium, x: 0, y: 0, height: nil, width: nil) 
    content_tag :div do
      image_tag(image.image_file(size), style: "position:absolute; left: 100px; top: 50px; clip: rect(#{x}px,#{y}px,#{height}px,#{width}px);", width: image.width, height: image.height).html_safe
    end
  end  

end
