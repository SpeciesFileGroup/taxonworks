module ImagesHelper

  # !! Rails already provides image_tag, i.e. it is not required here.

  def image_link(image, size: :thumb)
    return nil if image.nil?
    link_to(image_tag(image.image_file.url(size)), image)
  end

  def images_search_form
    render('/images/quick_search_form')
  end

  # @return [String]
  #   like `jpeg`, `png`
  def image_type(image)
    image.image_file.content_type.split('/').last.downcase
  end


  # "/images/scale_to_box/:x/:y/:width/:height/:box_width/:box_height"
  def original_as_scaled_png_via_api(image, api: true)
    h = image.height
    w = image.width

    s = api ? '/api/v1' : ''

    s << "/images/#{image.id}/scale_to_box/0/0/#{w}/#{h}/#{w}/#{h}"
    s
  end

  # "/images/:1/as_png"
  def original_as_png_via_api(image, api: true)
    s = api ? '/api/v1' : ''

    s << "/images/#{image.id}/as_png"
    s
  end

  # Return a ShortenedUrl to the original file image
  # @params image [Image, Integer]
  def image_short_url(image, api: true)
    if !image.kind_of?(::Image) && (Integer(image) rescue false)
      image = ::Image.find(image)
    end

    if api
      short_url( api_v1_images_file_sha_url( sha: image.image_file_fingerprint ) )
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

  def thumb_list_tag(object)
    if object.depictions.any?
      object.depictions.collect{|a|
        content_tag(:div)  do
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

  UNATTRIBUTED_IMAGE_MESSAGE =
    'Image is not accessible via the API because it lacks attribution.'

  # The single source of truth for what an Image looks like in an API response:
  # real file URLs when attributed, a redaction message when not. Used everywhere
  # an Image (or a Depiction's image) is serialized for the API - merge the result
  # in and add whatever context-specific fields the caller needs on top.
  #
  # @return Hash
  def image_api_attributes(image, api: true)
    return {
      attributed: false,
      content_type: image.image_file_content_type,
      message: UNATTRIBUTED_IMAGE_MESSAGE
    } unless image.attributed?

    {
      attributed: true,
      content_type: image.image_file_content_type,
      image_file_file_name: image.image_file_file_name,
      original: short_url(image.image_file),
      thumb: short_url(image.image_file.url(:thumb)),
      medium: short_url(image.image_file.url(:medium)),
      original_png: original_as_scaled_png_via_api(image, api:),
      as_png: original_as_png_via_api(image, api:)
    }
  end

  # Integrate images and Depictions for concise, Otu-based responses
  # that are sortable by depiction type context. Somewhat convoluted.
  #
  # @return Hash  {image_order:, images: }
  # @param sort_order Array of base-class names
  def image_inventory(depictions, api: true, sort_order: [])
    q = depictions
    sort_order = %w{Otu CollectionObject Observation} if sort_order.blank?

    depiction_metadata = {}
    images = {}

    # find_each strips order, don't use that here
    q.all.each do |d|
      depiction_metadata[d.depiction_object_type] ||= []
      depiction_metadata[d.depiction_object_type].push(
        {
          id: d.id,
          label: label_for_depiction(d),
          depiction_type: d.depiction_object_type,
          depiction_object_id: d.depiction_object_id,
          image_id: d.image_id
        }
      )

      images[d.image_id] ||= d.image
    end

    r = {}

    images.values.each do |i|
      p = image_api_attributes(i, api:).merge(depictions: [])

      if i.source
        p[:source] = {
          label: i.source.cached
        }
      end

      if i.attribution
        p[:attribution] = {
          label: label_for_attribution(i.attribution),
          license: CREATIVE_COMMONS_LICENSES[i.attribution.license]
        }
      end

      r[i.id] = p
    end

    # Recombine the data
    depiction_metadata.each do |t, v|
      v.each do |d|
        id = d[:image_id]
        r[id][:depictions].push d.select{|m,n| m != :image_id} # trim out the cross-referencing image_id
      end
    end

    # Calculate a sort order
    image_ids = images.keys
    image_order = []

    sort_order.each do |o|
      if depiction_metadata[o]
        depiction_metadata[o].each do |d|
          image_order.push d[:image_id]
        end
      end
    end

    image_order.uniq!

    # Put the non-requested sort image ids in order at the end
    image_order += (image_ids - image_order)

    return {
      image_order:,
      images: r
    }
  end

end
