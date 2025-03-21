module DepictionsHelper

  # Should this have Image?
  def depiction_tag(depiction, size: :thumb)
    return nil if depiction.nil?
    if depiction.from_sled?
      depictions_sled_tag(depiction, size: size)
      # depiction_svg_tag(depiction)
    else
      tag.figure do
        image_tag(depiction.image.image_file.url(size)) +
          tag.figcaption(image_context_depiction_tag(depiction))
      end
    end
  end

  # Only text, no HTML
  def label_for_depiction(depiction)
    return nil if depiction.nil?
    [
      label_for(depiction.depiction_object.metamorphosize).to_s + ':',
      [depiction.figure_label, depiction.caption].compact.join('. ') + '.',
    '(' + depiction.depiction_object_type.to_s + ').'
    #      ('Depicts ' + label_for(depiction.depiction_object.metamorphosize).to_s + ', ' + Utilities::Strings.a_label(depiction.depiction_object_type).to_s + '.'),
    ].compact.join(' ').gsub(/\.\./, '.').gsub(' . ', ' ')
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
      image_tag(depiction.sled_extraction_path(size), skip_pipeline: true) +
        content_tag(:figcaption, image_context_depiction_tag(depiction))
    end
  end

  # TODO: this should evolve, maybe, into an IIIF response
  # with the context being the depictied object.
  def depiction_to_json(depiction)
    return nil if depiction.nil?
    a = {
      caption: depiction.caption,
      figure_label: depiction.figure_label,
      position: depiction.position,
      thumb: short_url(depiction.image.image_file.url(:thumb)),
      medium: short_url(depiction.image.image_file.url(:medium)),
      content_type: depiction.image.image_file_content_type,
      original_png: original_as_png_via_api(depiction.image)
    }
    a
  end

end
