module DepictionsHelper

  def depiction_tag(depiction, size: :thumb)
    return nil if depiction.nil?
    # TODO: fork clipped versus not here?!

    if depiction.from_sled?
      depictions_sled_tag(depiction)
      # depiction_svg_tag(depiction)
    else
      image_tag(depiction.image.image_file.url(:thumb)) + ' ' + image_context_depiction_tag(depiction)
    end
  end

  def image_context_depiction_tag(depiction)
    return nil if depiction.nil?
    object_link(depiction.depiction_object.metamorphosize)
  end

  def depiction_svg_tag(depiction)
    anchor = "clip_#{depiction.id}"
    content_tag(:svg, {foo: nil, "viewBox" => depiction.svg_view_box, xmlns: "http://www.w3.org/2000/svg", 'xmlns:xlink' => "http://www.w3.org/1999/xlink"}) do
      ( content_tag('clip-path', depiction.svg_clip, id: anchor ).html_safe +
       content_tag(:image, href: depiction.image.image_file.url, 'clip-path' => "url(##{anchor})" ).html_safe
      ).html_safe
    end
  end

  def depictions_sled_tag(depiction)
    image_tag(depiction.sled_thumb_path) + ' ' + image_context_depiction_tag(depiction)
  end

end
