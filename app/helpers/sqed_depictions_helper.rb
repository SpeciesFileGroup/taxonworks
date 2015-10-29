module SqedDepictionsHelper

  def sqed_depiction_tag(sqed_depiction)
    return nil if sqed_depiction.nil?
    image_tag(sqed_depiction.depiction.image.image_file.url(:thumb)) + " on " + object_tag(sqed_depiction.depiction.depiction_object.metamorphosize)
  end

  def sqed_depiction_link(sqed_depiction)
    return nil if sqed_depiction.nil?
    link_to(sqed_depiction_tag(sqed_depiction), sqed_depiction.depiction)
  end

end
