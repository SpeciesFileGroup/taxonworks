module Tasks::Gis::OtuDistributionDataHelper
  def otu_aggregation(otu)
    retval = otu.distribution_geoJSON
    retval['properties']['tag'] = object_tag(otu)
    retval
  end
end
