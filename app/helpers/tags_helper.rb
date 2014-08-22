module TagsHelper

  def self.tag_tag(tag)
    return nil if tag.nil?
    tag.keyword.name
  end

  def tag_tag(tag)
    TagsHelper.tag_tag(tag)
  end

  def tags_search_form
    render '/tags/quick_search_form'
  end

  def tag_link(tag)
    return nil if tag.nil?
    link_to(tag_tag(tag).html_safe, tag)
  end

end
