require 'rails_helper'

describe AssertedDistribution, type: :model, group: :geo do

  let(:asserted_distribution) { FactoryGirl.build(:asserted_distribution) }

  # foreign key relationships
  context 'associations' do
    context 'belongs_to' do
      specify 'otu' do
        expect(asserted_distribution.otu = Otu.new).to be_truthy
      end

#      specify 'source' do
#        expect(asserted_distribution.source = Source.new).to be_truthy
#      end

      specify 'geographic_area' do
        expect(asserted_distribution.geographic_area = GeographicArea.new).to be_truthy
      end
    end
  end

  context 'validation' do
    specify 'duplicate record' do
      ad1 = FactoryGirl.create(:valid_asserted_distribution)
#      ad2 = FactoryGirl.build_stubbed(:valid_asserted_distribution, otu_id: ad1.otu_id, source_id: ad1.source_id, geographic_area_id: ad1.geographic_area_id)
      ad2 = FactoryGirl.build_stubbed(:valid_asserted_distribution, otu_id: ad1.otu_id, geographic_area_id: ad1.geographic_area_id)
      expect(ad1.valid?).to be_truthy
      expect(ad2.valid?).to be_falsey
      expect(ad2.errors.include?(:geographic_area_id)).to be_truthy
    end
    
    specify 'missing fields' do
#      ad1 = FactoryGirl.build_stubbed(:valid_asserted_distribution, otu_id: nil, source_id: nil, geographic_area_id: nil)
      ad1 = FactoryGirl.build_stubbed(:valid_asserted_distribution, otu_id: nil, geographic_area_id: nil)
      expect(ad1.valid?).to be_falsey
      expect(ad1.errors.include?(:geographic_area_id)).to be_truthy
#      expect(ad1.errors.include?(:source_id)).to be_truthy
     
       expect(ad1.errors.include?(:otu)).to be_truthy
    end
  end

  context 'soft validation' do
    # Can't miss source, it's required by definition
    specify 'is_absent - False' do
      ga  = FactoryGirl.create(:level2_geographic_area)
      ad1 = FactoryGirl.create(:valid_asserted_distribution, geographic_area: ga.parent, is_absent: 1)
      ad2 = FactoryGirl.build_stubbed(:valid_asserted_distribution, geographic_area: ga)
      ad2.soft_validate(:conflicting_geographic_area)
      expect(ad2.soft_validations.messages_on(:geographic_area_id).count).to eq(1)
    end
    specify 'is_absent - True' do
      ga  = FactoryGirl.create(:level2_geographic_area)
      ad1 = FactoryGirl.create(:valid_asserted_distribution, geographic_area: ga)
      ad2 = FactoryGirl.build_stubbed(:valid_asserted_distribution, geographic_area: ga, is_absent: 1)
      ad2.soft_validate(:conflicting_geographic_area)
      expect(ad2.soft_validations.messages_on(:geographic_area_id).count).to eq(1)
    end
  end

  context 'stub_new' do

    let(:otu) { FactoryGirl.create(:valid_otu) }
#    let(:source) { FactoryGirl.create(:valid_source) }

    before(:all) do
      generate_political_areas_with_collecting_events
    end

    after(:all) {
      clean_slate_geo
    }

    specify 'creates some number of ADs' do
      # pending
      point = @gr_n3_ob.geographic_item.geo_object
      areas = GeographicArea.find_by_lat_long(point.y, point.x)
      stubs = AssertedDistribution.stub_new({'otu_id'           => otu.id,
#                                             'source_id'        => source.id,
                                             'geographic_areas' => areas}).map(&:geographic_area)
      expect(stubs.map(&:name)).to include('Great Northern Land Mass', 'Old Boxia', 'R', 'RN3', 'N3')
    end
  end

  context 'concerns' do
    it_behaves_like 'notable'
  end


end
