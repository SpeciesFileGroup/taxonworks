require 'rails_helper'

RSpec.describe Observation::Qualitative, type: :model, group: :matrix do
  let(:observation) { Observation::Qualitative.new } 

  context 'validation' do
    before { observation.valid? }

    specify '#character_state_id required' do
      expect(observation.errors.include?(:character_state_id)).to be_truthy
    end

    specify '#frequency required' do
      expect(observation.errors.include?(:frequency)).to be_truthy
    end
  end
end
