require 'spec_helper'

BaseDir = '../shapes/'

# TODO: RGeo Shapefile processing: Conversations about the following issues:
# TODO:   Use of PID from the USA or GADM shape files: include it in the GeographicArea model?
# TODO:   Where/how to generate the real GeoJSON (RGeo::GeoJSON.encode(object) does not seem to work properly)
# TODO:   Our TDWG shape files are *not* in the form readable by RGeo::Shapefile::Reader, because they lack the attending index and attribute files.  The question becomes "Do we write a reader in Ruby, or is there a better (perhaps existing) choice?"
# TODO:   Do we keep the TDWG/GADM shapes in a separate table? (Gazetteer?)

describe GeographicArea do
  let(:geographic_area)  {FactoryGirl.build(:geographic_area)}

  context 'validation' do
    before(:each) {
      geographic_area.valid? 
    }

    context 'required fields' do
      specify 'name' do
        expect(geographic_area.errors.include?(:name)).to be_true 
      end

      specify 'data_origin' do
        expect(geographic_area.errors.include?(:data_origin)).to be_true 
      end

      specify 'geographic_area_type' do
        expect(geographic_area.errors.include?(:geographic_area_type)).to be_true 
      end
    end
  end

  context 'associations' do
    context 'belongs_to' do
      specify "parent" do
        expect(geographic_area).to respond_to(:parent)
      end
      specify "tdwg_parent" do
        expect(geographic_area).to respond_to(:tdwg_parent)
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
      specify 'gadm_geo_item' do
        expect(geographic_area).to respond_to(:gadm_geo_item)
      end
      specify 'tdwg_geo_item' do
        expect(geographic_area).to respond_to(:tdwg_geo_item)
      end
      specify 'ne_geo_item' do
        expect(geographic_area).to respond_to(:ne_geo_item)
      end
    end

    context 'nesting' do
      context 'parents' do
        before(:each) { 
          @champaign = FactoryGirl.create(:level2_geographic_area)
        }

        specify 'lft,rgt' do
          expect(@champaign.lft > 0).to be_true 
          expect(@champaign.rgt > 0).to be_true 
        end

        specify 'parent string' do
          expect(@champaign.name).to eq('Champaign')
          expect(@champaign.parent.name).to eq('Illinois')
          expect(@champaign.parent.parent.name).to eq('United States')
          expect(@champaign.parent.parent.parent.name).to eq('Earth')
        end

        specify 'ancestors' do
          expect(@champaign.ancestors).to eq([@champaign.parent.parent.parent, @champaign.parent.parent, @champaign.parent])
        end

        specify 'root' do
          expect(@champaign.root.name).to eq('Earth')
        end
 
        specify 'descendents' do
          expect(@champaign.root.descendants).to have(3).things
        end
      end

   end
  end

  context 'search functions' do
    before(:each) { 
      @champaign = FactoryGirl.create(:level2_geographic_area)
   }
   
    specify 'should be able to find a country by ISO_A3' do
      expect(GeographicArea.where(:iso_3166_a3 => 'USA').first.name).to eq("United States")
    end
  
    context 'scopes' do
      specify 'countries' do
        expect(GeographicArea.countries).to eq( [@champaign.parent.parent]  )
      end
    end 
  end


end
