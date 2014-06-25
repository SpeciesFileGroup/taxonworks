require 'spec_helper'

describe AssertedDistribution do

  let(:asserted_distribution) { FactoryGirl.build(:asserted_distribution) }

  # foreign key relationships
  context 'associations' do
    context 'belongs_to' do
      specify 'otu' do
        expect(asserted_distribution.otu = Otu.new).to be_truthy 
      end

      specify 'source' do
        expect(asserted_distribution.source = Source.new).to be_truthy 
      end

      specify 'geographic_area' do
        expect(asserted_distribution.geographic_area = GeographicArea.new).to be_truthy
      end
    end
  end

  context 'soft validation' do
    # Can't miss source, it's required by definition
   specify 'is_absent - False' do
      ga = FactoryGirl.create(:level2_geographic_area)
      ad1 = FactoryGirl.create(:valid_asserted_distribution, geographic_area: ga.parent, is_absent: TRUE)
      ad2 = FactoryGirl.build_stubbed(:valid_asserted_distribution, geographic_area: ga)
      ad2.soft_validate(:conflicting_geographic_area)
      expect(ad2.soft_validations.messages_on(:geographic_area_id).count).to eq(1)
    end
    specify 'is_absent - True' do
      ga = FactoryGirl.create(:level2_geographic_area)
      ad1 = FactoryGirl.create(:valid_asserted_distribution, geographic_area: ga)
      ad2 = FactoryGirl.build_stubbed(:valid_asserted_distribution, geographic_area: ga, is_absent: TRUE)
      ad2.soft_validate(:conflicting_geographic_area)
      expect(ad2.soft_validations.messages_on(:geographic_area_id).count).to eq(1)
    end
  end

end
