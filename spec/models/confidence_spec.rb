require 'rails_helper'

RSpec.describe Confidence, type: :model, group: :confidence do

  let(:confidence) { Confidence.new }
  let(:confidence_level) { FactoryGirl.create(:valid_confidence_level) }
  let(:specimen) { FactoryGirl.create(:valid_specimen) }

  context 'validation' do
    before { confidence.save }

    specify 'confidence_level_id' do
      expect(confidence.errors.include?(:confidence_level)).to be_truthy
    end
  end

  context 'associations' do
    specify '#confidence_level' do
      expect(confidence.confidence_level = ConfidenceLevel.new()).to be_truthy
    end

    specify '#confidence_object' do
      expect(confidence.confidence_object = Specimen.new()).to be_truthy
    end
  end 

  specify '#annotated_global_entity' do
    confidence.annotated_global_entity = specimen.to_global_id.to_s
    confidence.confidence_level_id = confidence_level.id 
    expect(confidence.save!).to be_truthy
  end

end
