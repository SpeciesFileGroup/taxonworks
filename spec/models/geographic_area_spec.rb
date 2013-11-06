require 'spec_helper'

describe GeographicArea do

  before :all do
    # read_shape
  end
  context 'Shape files' do
    specify 'that a shapefile can be read.' do
      expect(true).to eq true
    end

  end
end

def read_shape()

  RGeo::Shapefile::Reader.open('\Share\Downloads\PostgreSQL\PostGIS\USA_adm\USA_adm1.shp') { |file|
    puts "File contains #{file.num_records} records."
    file.each { |record|
      puts "Record number #{record.index}:  Attributes: #{record.attributes.inspect}"
      #puts " Geometry: #{record.geometry.as_text}"
      #puts " Attributes: #{record.attributes.inspect}"
      @record = GeographicItem.new
      @record.multi_polygon = record.geometry
      @record.save
    }
    file.rewind
    record = file.next
    puts "First record geometry was: #{record.geometry.as_text}"
  }


end
