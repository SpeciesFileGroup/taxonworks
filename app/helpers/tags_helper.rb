module TagsHelper

  def self.tag_tag(tag)
    return nil if tag.nil?
    tag.keyword.name
  end

  def tag_tag(tag)
    TagsHelper.tag_tag(tag)
  end


end
