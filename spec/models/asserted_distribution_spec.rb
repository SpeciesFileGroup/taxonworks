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
  end

end
