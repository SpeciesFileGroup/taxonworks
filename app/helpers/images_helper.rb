module ImagesHelper

  # !! Rails already provides image_tag, i.e. it is not required here.

  def image_link(image, size: :thumb)
    return nil if image.nil?
    link_to(image_tag(image.image_file.url(size)), image)
  end

  def images_search_form
    render('/images/quick_search_form')
  end

  # Return a ShortenedUrl to the original file image
  # @params image [Image, Integer]
  def image_short_url(image: api: true)
    if !image.kind_of?(::Image)
      image = ::Image.find(image)
    end

    if api
      short_url( api_v1_image_file_path( image) )
    else
      short_url( image.image_file.url(:original) )
    end
  end

  # @return [True]
  #   indicates a custom partial should be used, see list_helper.rb
  def images_recent_objects_partial
    true 
  end

  def image_autocomplete_tag(image)
    content_tag(:figure) do
      (
        image_tag(image.image_file.url(:thumb)) +
        content_tag(:caption, "id:#{image.id}", class: ['feedback', 'feedback-primary', 'feedback-thin']) 
      ).html_safe
    end
  end

  # <div class="easyzoom easyzoom--overlay">
  #   <a href="<%= @image.image_file.url(:medium) %>">
  #     <%= image_tag(@image.image_file.url(:medium), 'class' => 'imageZoom') %>
  #   </a>
  # </div>

  def thumb_list_tag(object)
    if object.depictions.any?
      object.depictions.collect{|a|
        content_tag(:div, class: [:easyzoom, 'easyzoom--overlay'])  do
          link_to( depiction_tag(a, size: :medium), a.image.image_file.url())
        end
      }.join.html_safe
    end
  end

  def image_display_url(image)
    case image.image_file_content_type
    when 'image/tiff'
      "/images/#{image.id}/extract/0/0/#{image.width}/#{image.height}"
    else
      root_url + image.image_file.url[1..-1]
    end
  end

end
