require 'spec_helper'

BaseDir = '../shapes/'

# TODO: RGeo Shapefile processing: Conversations about the following issues:
# TODO:   Use of PID from the USA or GADM shape files: include it in the GeographicArea model?
# TODO:   Where/how to generate the real GeoJSON (RGeo::GeoJSON.encode(object) does not seem to work properly)
# TODO:   Our TDWG shape files are *not* in the form readable by RGeo::Shapefile::Reader, because they lack the attending index and attribute files.  The question becomes "Do we write a reader in Ruby, or is there a better (perhaps existing) choice?"
# TODO:   Do we keep the TDWG/GADM shapes in a separate table? (Gazetteer?)

describe GeographicArea do

  #before :all do
  #end

  let(:geographic_area)  {FactoryGirl.create(:c_geographic_area)}

  context 'validation' do
    before do

    end

    specify 'name is required' do

    end
  end

  context 'associations' do
    context 'belongs_to' do

      #before :each do
      #  let(:geographic_area) {FactoryGirl.build(:c_geographic_area)}
      #end

      specify "should " do
        expect(geographic_area).to respond_to(:parent)
      end
    end

    context 'validation' do

      before :each do
        #let(:geographic_area) {FactoryGirl.build(:c_geographic_area)}
      end

      specify 'parent' do
        expect(geographic_area).to respond_to(:parent)
      end
      specify 'level0' do
        expect(geographic_area).to respond_to(:level0)
      end
      specify 'level1' do
        expect(geographic_area).to respond_to(:level1)
      end
      specify 'level2' do
        expect(geographic_area).to respond_to(:level2)
      end
    end

  end

  #context 'Shape files' do
  #  specify 'that a shapefile can be read.' do
  #    filenames = Dir.glob(BaseDir + 'gadm_v2_shp/**/*.shp')
  #    filenames.sort! # get the first one
  #    filenames.each { |filename|
  #      RGeo::Shapefile::Reader.open(filename) { |file|

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
          #puts filename
          #should be
          #   ../shapes/gadm_v2_shp/gadm2.shp
          #expect(file.num_records).to eq 218238
        #} # just read the gadm2 shape file
      #}
    #
    #end
  #
  #end
end
