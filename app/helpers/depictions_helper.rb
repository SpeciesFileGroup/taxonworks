module DepictionsHelper

  def depiction_tag(depiction)
    return nil if depiction.nil?
    image_tag(depiction.image.image_file.url(:thumb)) + ' ' + image_context_depiction_tag(depiction)
  end

  def image_context_depiction_tag(depiction)
    return nil if depiction.nil?
    object_link(depiction.depiction_object.metamorphosize)
  end

end
