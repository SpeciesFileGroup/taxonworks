require 'rails_helper'

# TODO:   Where/how to generate the real GeoJSON (RGeo::GeoJSON.encode(object) does not seem to work properly)

describe GeographicArea, :type => :model do
  let(:geographic_area) { FactoryGirl.build(:geographic_area_stack) }

  context 'validation' do
    before(:each) {
      geographic_area.valid?
    }

    context 'required fields' do
      specify 'name' do
        expect(geographic_area.errors.include?(:name)).to be_truthy
      end

      specify 'blank names are invalid' do
        geographic_area.name = ''
        geographic_area.valid?
        expect(geographic_area.errors.include?(:name)).to be_truthy
      end

      specify 'names are minimum length' do
        geographic_area.name = '1'
        geographic_area.valid?
        expect(geographic_area.errors.include?(:name)).to be_falsey
      end

      specify 'data_origin' do
        expect(geographic_area.errors.include?(:data_origin)).to be_truthy
      end

      specify 'geographic_area_type' do
        expect(geographic_area.errors.include?(:geographic_area_type)).to be_truthy
      end
    end
  end

  context 'instance methods' do
    specify "#tdwg_ids" do
      geographic_area.tdwgID = '41SCS-PI'
      expect(geographic_area.tdwg_ids[:lvl1]).to eq('4')
      expect(geographic_area.tdwg_ids[:lvl2]).to eq('41')
      expect(geographic_area.tdwg_ids[:lvl3]).to eq('SCS')
      expect(geographic_area.tdwg_ids[:lvl4]).to eq('SCS-PI')
    end

    specify "#tdwg_level" do
      geographic_area.data_origin = 'TDWG2 Level 1'
      expect(geographic_area.tdwg_level).to eq('1')
    end
  end

  context 'associations' do
    context 'belongs_to' do
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

      specify 'geo_object' do
        expect(geographic_area).to respond_to(:geo_object)
      end

      context 'has_many' do
        specify 'children_at_level1' do
          expect(geographic_area).to respond_to(:children_at_level1)
        end
        specify 'children_at_level2' do
          expect(geographic_area).to respond_to(:children_at_level2)
        end
      end
    end

    context 'nesting' do
      context 'parents' do
        before(:each) {
          @champaign = FactoryGirl.create(:level2_geographic_area)
        }

        specify 'lft, rgt' do
          expect(@champaign.lft > 0).to be_truthy
          expect(@champaign.rgt > 0).to be_truthy
        end

        specify 'parent string' do
          expect(@champaign.name).to eq('Champaign')
          expect(@champaign.parent.name).to eq('Illinois')
          expect(@champaign.parent.parent.name).to eq('United States of America')
          expect(@champaign.parent.parent.parent.name).to eq('Earth')
        end

        specify 'ancestors' do
          expect(@champaign.ancestors).to eq([@champaign.root, @champaign.parent.parent, @champaign.parent])
        end

        specify 'root' do
          expect(@champaign.root.name).to eq('Earth')
        end

        specify 'descendants' do
          expect(@champaign.root.descendants.count).to eq(3)
        end
      end
    end
  end

  context 'search functions' do
    before(:each) {
      @champaign = FactoryGirl.create(:level2_geographic_area)
      @illinois = @champaign.parent
      @usa = @illinois.parent
      @earth = @usa.parent
    }

    specify 'should be able to find a country by ISO_A2' do
      expect(GeographicArea.where(:iso_3166_a2 => 'US').first.name).to eq('United States of America')
    end

    specify 'should be able to find a country by ISO_A3' do
      expect(GeographicArea.where(:iso_3166_a3 => 'USA').first.name).to eq('United States of America')
    end

    context 'scopes/AREL' do
      specify 'children_at_level1' do
        expect(@champaign.children_at_level1.count).to eq(0)
        expect(@champaign.root.children_at_level1.count).to eq(1)
        expect(@champaign.parent.parent.children_at_level1.count).to eq(1)
      end

      specify 'children_at_level2' do
        expect(@champaign.children_at_level2.count).to eq(0)
        expect(@champaign.root.children_at_level2.count).to eq(1)
        expect(@champaign.parent.children_at_level2.count).to eq(1)
      end

      specify 'descendants_of' do
        expect(GeographicArea.descendants_of(@champaign.root)).to eq([@champaign.parent.parent, @champaign.parent, @champaign])
      end

      specify 'ancestors_of' do
        expect(GeographicArea.ancestors_of(@champaign)).to eq([@champaign.root, @champaign.parent.parent, @champaign.parent])
      end

      specify 'ancestors_and_descendants_of' do
        expect(GeographicArea.ancestors_and_descendants_of(@champaign.parent)).to eq([@champaign.root, @champaign.parent.parent, @champaign])
      end

      specify 'countries' do
        expect(GeographicArea.countries).to include(@champaign.parent.parent)
      end

      specify 'descendants_of_geographic_area_type' do
        expect(@champaign.root.descendants_of_geographic_area_type('County').to_a).to eq([@champaign])
        expect(@champaign.root.descendants_of_geographic_area_type('State').to_a).to eq([@champaign.parent])
        expect(@champaign.root.descendants_of_geographic_area_type('Province').to_a).to eq([])
      end

      specify 'descendants_of_geographic_area_types' do
        expect(@champaign.root.descendants_of_geographic_area_types(['County', 'State', 'Province']).to_a).to eq([@champaign.parent, @champaign])
      end

      specify '::with_name_and_parent_name' do
        # single immediate parent name
        expect(GeographicArea.with_name_and_parent_name(%w(Champaign Illinois)).to_a).to eq([@champaign])
        # single immediate parent name not in list
        expect(GeographicArea.with_name_and_parent_name(%w(Champaign Ohio)).to_a).to eq([])
      end

      specify '::with_name_and_parent_names' do
        # multiple parent name
        expect(GeographicArea.with_name_and_parent_names(%w(Champaign Illinois United\ States\ of\ America)).to_a).to eq([@champaign])
        # multiple parent name not in list
        expect(GeographicArea.with_name_and_parent_names(%w(Champaign Ohio United\ States\ of\ America)).to_a).to eq([])
      end

      specify '::find_by_self_and_parents' do
        # one name
        expect(GeographicArea.find_by_self_and_parents(%w(Champaign)).to_a).to eq([@champaign])
        # two names
        expect(GeographicArea.find_by_self_and_parents(%w(Champaign Illinois)).to_a).to eq([@champaign])
        # three names
        expect(GeographicArea.find_by_self_and_parents(%w(Champaign Illinois United\ States\ of\ America)).to_a).to eq([@champaign])
        # two names not in list
        expect(GeographicArea.find_by_self_and_parents(%w(Champaign Ohio)).to_a).to eq([])
        # three names not in list
        expect(GeographicArea.find_by_self_and_parents(%w(Champaign Ohio United\ States\ of\ America)).to_a).to eq([])

      end
    end
  end

  # TODO: cleanup/extend
  context 'interaction with geographic_items' do
    # after(:all) {
    #   GeographicArea.destroy_all
    # }
    before(:each) {
      @geographic_area = FactoryGirl.create(:level2_geographic_area)
      @gi              = GeographicItem.create!(polygon: RSPEC_GEO_FACTORY.polygon(LIST_K))
      @geographic_area.geographic_areas_geographic_items << GeographicAreasGeographicItem.new(geographic_item: @gi, data_origin: 'SFG')
      @geographic_area.save
      @gi
    }

    specify 'retrieving the geo_object' do
      expect(@geographic_area.default_geographic_item).to eq(@gi)
    end
  end

  context 'geolocate_params_string' do
    before(:all) {
      @geographic_area = FactoryGirl.create(:level2_geographic_area)
    }
    specify 'retrieving geolocate parameters as a string' do
      pending 'completion of method'
      expect(geographic_area.geolocate_params_string).to eq('country=United States of America&state=Illinois&locality=Champaign')
    end
  end

end
