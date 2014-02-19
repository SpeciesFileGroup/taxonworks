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
  #let(:geographic_area)  {FactoryGirl.build(:c_geographic_area)}

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

    context 'validation of ' do

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
      specify 'parent string' do
        expect(geographic_area.name).to eq('Champaign')
        expect(geographic_area.parent.name).to eq('Illinois')
        expect(geographic_area.parent.parent.name).to eq('United States')
        expect(geographic_area.parent.parent.parent.name).to eq('Earth')
      end
    end

  end

  context 'search functions' do
    specify 'should be able to find a country by ISO_A3' do
      expect(GeographicArea.where(:iso_3166_a3 => 'USA').first.name).to eq("United States")
    end
    specify "should return a list of countries from the database." do
      expect(GeographicArea.countries.names).to eq(['United States'])
    end
  end


end
