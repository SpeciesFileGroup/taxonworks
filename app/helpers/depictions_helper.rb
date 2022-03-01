module DepictionsHelper

  # Should this have Image?
  def depiction_tag(depiction, size: :thumb)
    return nil if depiction.nil?
    if depiction.from_sled?
      depictions_sled_tag(depiction, size: size)
      # depiction_svg_tag(depiction)
    else
      tag.figure do
        tag.image(depiction.image.image_file.url(size)) +
          tag.figcaption(image_context_depiction_tag(depiction))
      end
    end
  end

  # Only text, no HTML
  def label_for_depiction(depiction)
    return nil if depiction.nil?

    label_for(depiction.depiction_object.metamorphosize)
  end

  def image_context_depiction_tag(depiction)
    return nil if depiction.nil?
    object_tag(depiction.depiction_object.metamorphosize)
  end

  # !! NOT USED
  #
  def depiction_svg_tag(depiction)
    anchor = "clip_#{depiction.id}"
    content_tag(:svg, {foo: nil, "viewBox" => depiction.svg_view_box, xmlns: "http://www.w3.org/2000/svg", 'xmlns:xlink' => "http://www.w3.org/1999/xlink"}) do
      ( content_tag('clip-path', depiction.svg_clip, id: anchor ).html_safe +
       content_tag(:image, href: depiction.image.image_file.url, 'clip-path' => "url(##{anchor})" ).html_safe
      ).html_safe
    end
  end

  def depictions_sled_tag(depiction, size: :thumb)
    content_tag(:figure) do
      image_tag(depiction.sled_extraction_path(size)) +
        content_tag(:figcaption, image_context_depiction_tag(depiction))
    end
  end

end
