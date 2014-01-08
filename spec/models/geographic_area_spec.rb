require 'spec_helper'

BaseDir = '../shapes/'

# TODO: RGeo Shapefile processing: Conversations about the following issues:
# TODO:   Use of PID from the USA or GADM shape files: include it in the GeographicArea model?
# TODO:   Where/how to generate the real GeoJSON (RGeo::GeoJSON.encode(object) does not seem to work properly)
# TODO:   Our TDWG shape files are *not* in the form readable by RGeo::Shapefile::Reader, because they lack the attending index and attribute files.  The question becomes "Do we write a reader in Ruby, or is there a better (perhaps existing) choice?"
# TODO:   Do we keep the TDWG/GADM shapes in a separate table? (Gazetteer?)

describe GeographicArea do

  before :all do
  end

  context 'Shape files' do
    specify 'that a shapefile can be read.' do
      Dir.glob(BaseDir + '**/*.shp').each { |filename|
        RGeo::Shapefile::Reader.open(filename) { |file|

=begin
          file.each { |item|
            record    = GeographicArea.new(parent_id:  item[:ID_1],
                                           name:       item[:NAME_2],
                                           state_id:   item[:ID_1],
                                           country_id: item[:ID_0],
                                           county_id:  item[:ID_2])
            area_type = GeographicAreaType.where(name: item[:TYPE_2])

            record.geographic_area_type          = area_type[0]
            record.geographic_item               = GeographicItem.new
            record.geographic_item.multi_polygon = item.geometry

            parent_record = GeographicArea.where({state_id: record.parent_id})[0]

            count = record.geographic_item.multi_polygon.num_geometries
            ess   = (count == 1) ? '' : 's'
            puts "#{record.geographic_area_type.name} of #{record.name} in the #{parent_record.geographic_area_type.name} of #{parent_record.name} => #{count} polygon#{ess}."
          }
=end
          expect(file.num_records).to eq 218238
        } if !(filename =~ /[01]/) # just read the counties
      }

    end

  end
end
