module TagsHelper

  def tag_tag(tag)
    return nil if tag.nil?
    tag.keyword.name
  end

  def new_tag_tag(taggable_object) # tag_object is to be tagged
    link_to('Tag',
            new_tag_path(tag_object_id: taggable_object.id, tag_object_type: taggable_object.class.name),
            id: "tag_splat_#{taggable_object.class}_#{taggable_object.id}"
           )
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

  def link_to_add_tag(link_text, f)
    new_object = f.object.class.reflect_on_association(:tags).klass.new(
      {tag_object_type:      f.object.class.base_class.name,
       tag_object_id:        f.object.id,
       tag_object_attribute: 'name'})
    fields = f.fields_for(:tags, new_object, :child_index => 'new_tags') do |builder|
      render('tags/tag_fields', :avf => builder)
    end
    link_to(link_text, '', class: 'tag-add', association: 'tags', content: "#{fields}")
  end

  def add_tag_link(object: nil, attribute: nil)
    link_to('Add tag', 
            new_tag_path(
              tag_object_type: object.class.base_class.name,
              tag_object_id: object.id,
              tag_object_attribute: attribute)) if object.has_tags?
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
