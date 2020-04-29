# A Georeference derived from the Leaflet plugin 
#
class Georeference::Leaflet < Georeference


    def dwc_georeference_attributes
    h = { 
      footprintWKT: geographic_item.geo_object.to_s,

      georeferenceSources: 'Leaflet',
      georeferenceRemarks: 'Created from a TaxonWorks interface that integrates Leaflet.',
      georeferenceProtocol: 'Shape "drawn" on a Leaflet map.',
      georeferenceVerificationStatus: confidences&.collect{|c| c.name}.join('; '), 
      georeferencedBy: created_by.name,
      georeferencedDate: created_at
    }

    if geographic_item.type == 'GeographicItem::Point' 
      h[:decimalLatitude] = geographic_item.to_a.first
      h[:decimalLongitude] = geographic_item.to_a.last
      h[:coordinateUncertaintyInMeters] = error_radius 
    end

    h
  end

end
