module GeoreferencesHelper

  # Needs to turn into a gmap with the item displayed
  def georeference_tag(georeference)
    return nil if georeference.nil?
    georeference.to_param 
  end

end
