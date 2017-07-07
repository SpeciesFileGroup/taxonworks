require 'rails_helper'

RSpec.describe Observation::Qualitative, type: :model, group: :matrix do
  let(:observation) { Observation::Qualitative.new } 

  context 'validation' do
    before { observation.valid? }

    specify '#character_state required' do
      expect(observation.errors.include?(:character_state)).to be_truthy
    end
  end
end
