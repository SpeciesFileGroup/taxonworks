module TagsHelper

  def tag_tag(tag)
    return nil if tag.nil?

    [tag.keyword.name,
     tag.tag_object_type,
     object_tag(tag.tag_object)
    ].compact.join(' : ')
  end

    def tags_search_form
    render '/tags/quick_search_form'
  end

  def tag_link(tag)
    return nil if tag.nil?
    link_to(tag_tag(tag).html_safe, metamorphosize_if(tag.tag_object))
  end

  def link_to_destroy_tag(link_text, tag)
    link_to(link_text, '', class: 'tag-destroy', tag_id: tag.id)
  end

  def add_tag_link(object: nil, attribute: nil) # tag_object is to be tagged
    link_to('Add tag',
            new_tag_path(tag_object_id: object.id, tag_object_type: object.class.name, tag_object_attribute: attribute),
            id: "tag_splat_#{object.class}_#{object.id}"
            # José - icon via class and or data-attribute here
           )
  end

  def destroy_tag_link(tag)
    destroy_object_link(tag)
  end

  # @return [True]
  #   indicates a custom partial should be used, see list_helper.rb
  def tags_recent_objects_partial
    true
  end

  # @return [String (html), nil]
  #    a ul/li of tags for the object
  def tag_list_tag(object)
    if object.tags.any?
      content_tag(:h3, 'Tags') +
      content_tag(:ul, class: 'tag_list') do
        object.tags.collect { |a| content_tag(:li, tag_tag(a)) }.join.html_safe
      end
    end
  end

end
