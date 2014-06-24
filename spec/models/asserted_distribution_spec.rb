require 'spec_helper'

describe AssertedDistribution do

  let(:asserted_distribution) { AssertedDistribution.new }

  # foreign key relationships
  context 'reflections / foreign keys' do
    context 'respond to' do

      specify 'otu' do
        expect(asserted_distribution).to respond_to(:otu)
      end

      specify 'source' do
        expect(asserted_distribution).to respond_to(:source)
      end

      specify 'geographic_area' do
        expect(asserted_distribution).to respond_to(:geographic_area)
      end
    end
  end

  context 'soft validation' do
    specify 'missing source' do
      ad = FactoryGirl.build_stubbed(:valid_asserted_distribution, source: nil)
      ad.soft_validate(:missing_source)
      expect(ad.soft_validations.messages_on(:source_id).count).to eq(1)
      ad.source_id = 1
      ad.soft_validate(:missing_source)
      expect(ad.soft_validations.messages_on(:source_id).empty?).to be_truthy
    end
    specify 'is_absent - False' do
      ga = FactoryGirl.create(:level2_geographic_area)
      ad1 = FactoryGirl.create(:valid_asserted_distribution, geographic_area: ga.parent, is_absent: TRUE, source: nil)
      ad2 = FactoryGirl.build_stubbed(:valid_asserted_distribution, geographic_area: ga, source: nil)
      ad2.soft_validate(:conflicting_geographic_area)
      expect(ad2.soft_validations.messages_on(:geographic_area_id).count).to eq(1)
    end
    specify 'is_absent - True' do
      ga = FactoryGirl.create(:level2_geographic_area)
      ad1 = FactoryGirl.create(:valid_asserted_distribution, geographic_area: ga, source: nil)
      ad2 = FactoryGirl.build_stubbed(:valid_asserted_distribution, geographic_area: ga, is_absent: TRUE, source: nil)
      ad2.soft_validate(:conflicting_geographic_area)
      expect(ad2.soft_validations.messages_on(:geographic_area_id).count).to eq(1)
    end

  end

end
