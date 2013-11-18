require 'spec_helper'

BaseDir = '../shapes/'

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
          expect(file.num_records).to eq 3145
        } if !(filename =~ /[01]/) # just read the counties
      }

    end

  end
end
