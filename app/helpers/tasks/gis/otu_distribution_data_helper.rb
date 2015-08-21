module Tasks::Gis::OtuDistributionDataHelper
  def otu_aggregation(otu)
    retval                      = otu.distribution_geoJSON
    retval['properties']['tag'] = object_tag(otu)
    retval
  end

  def without_shape?(distributions)
    count = 0
    distributions.each { |dist|
      count += 1 if dist.geographic_area.geographic_items.count == 0
    }
    ", #{count} without shape" if count > 0
  end
end
