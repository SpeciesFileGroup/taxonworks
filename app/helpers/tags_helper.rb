module TagsHelper

  def tag_tag(tag)
    return nil if tag.nil?
    pieces =  [controlled_vocabulary_term_tag(tag.keyword), tag.tag_object_type, object_tag(tag.tag_object)]
    pieces.compact.join(': ').html_safe
  end

  def tag_annotation_tag(tag)
    return nil if tag.nil?
    content_tag(:span, controlled_vocabulary_term_tag(tag.keyword))
  end

  # @return [String (html), nil]
  #    a ul/li of tags for the object
  def tag_list_tag(object)
    return nil unless object.has_tags? && object.tags.load.any?
    content_tag(:h3, 'Tags') + tag_pills_tag(object)
  end

  def tag_pills_tag(object)
    return nil unless object.has_tags? && object.tags.load.any?
    content_tag(:ul, class: 'annotations__tag_list') do
      object.tags.collect { |a| content_tag(:li, tag_annotation_tag(a)) }.join.html_safe
    end
  end
  
  def tag_default_icon(object)
    content_tag(:span, 'Tag', 
      data: {
      'tag-default' => 'true',
      'tag-object-global-id' => object.to_global_id.to_s,
      'default-tagged-id' => is_default_tagged?(object),
      'inserted-keyword-count' => inserted_keyword_tag_count
      })
  end

  def tag_link(tag)
    return nil if tag.nil?
    link_to(tag_tag(tag), metamorphosize_if(tag.tag_object))
  end

  def link_to_destroy_tag(link_text, tag)
    link_to(link_text, '', class: 'tag-destroy', tag_id: tag.id)
  end

  def add_tag_link(object: nil, attribute: nil) # tag_object is to be tagged
    if object.has_tags?
      link_to('Add tag',
              new_tag_path(tag_object_id: object.id, tag_object_type: object.class.name, tag_object_attribute: attribute),
              id: "tag_splat_#{object.class}_#{object.id}"
             )
    else
      nil
    end
  end

  def destroy_tag_link(tag)
    destroy_object_link(tag)
  end

  # @return [True]
  #   indicates a custom partial should be used, see list_helper.rb
  def tags_recent_objects_partial
    true
  end

  # Session related helpers

  def inserted_keyword
    inserted_pinboard_item_object_for_klass('Keyword')
  end

  def inserted_keyword_tag_count
    inserted_keyword.try(:tags).try(:count)
  end

  # @return [Integer, false]
  #   true if the object is tagged, and is tagged with the keyword presently defaulted on the pinboard
  def is_default_tagged?(object)
    return false if object.blank?
    keyword = inserted_keyword
    return false if keyword.blank?
    t = Tag.where(tag_object: object, keyword: keyword).first.try(:id)
    t ? t : false
  end

end
