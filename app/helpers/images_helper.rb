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
  def original_as_png_via_api(image, api: true)
    h = image.height
    w = image.width

    s = api ? '/api/v1' : ''

    s << "/images/#{image.id}/scale_to_box/0/0/#{w}/#{h}/#{w}/#{h}"
    s
  end

  # Return a ShortenedUrl to the original file image
  # @params image [Image, Integer]
  def image_short_url(image, api: true)
    if !image.kind_of?(::Image) && (Integer(image) rescue false)
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

  # Integrate images and Depictions for concise, Otu-based responses
  # that are sortable by depiction type context
  def image_inventory(images, otu_id: nil, api: true, sort_order: [])

    sort_order = %w{Otu CollectionObject Observation} if sort_order.blank?

    q = ::Queries::Depiction::Filter.new(
      project_id: sessions_current_project_id,
      otu_id: [otu_id],
      otu_scope: :all
    ).all
      .eager_load(image: [:attribution])
      .order('depictions.depiction_object_type, depictions.depiction_object_id, depictions.position')

    depiction_metadata = {}
    images = {}

    q.all.find_each do |d|
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
      p = {
        original_png: original_as_png_via_api(i, api:),
        content_type: i.image_file_content_type,
        thumb: short_url(i.image_file.url(:thumb)),
        medium: short_url(i.image_file.url(:medium)),
        depictions: []
      }

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
        d.delete(:image_id)
        r[id][:depictions].push d  # depiction_metadata[t][d[:id].id]
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
