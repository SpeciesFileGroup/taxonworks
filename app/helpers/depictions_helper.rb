module DepictionsHelper

  def depiction_tag(depiction)
    return nil if depiction.nil?
    image_tag(depiction.image.image_file.url(:thumb)) + " " + object_tag(depiction.depiction_object.metamorphosize)
  end

end
