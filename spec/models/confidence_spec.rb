require 'rails_helper'

RSpec.describe Confidence, type: :model, group: :confidence do

  let(:confidence) { Confidence.new }

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

end
