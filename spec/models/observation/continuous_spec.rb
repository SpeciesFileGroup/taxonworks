require 'rails_helper'

RSpec.describe Observation::Continuous, type: :model, group: :matrix do
  let(:observation) { Observation::Continuous.new } 

  context 'validation' do
    before { observation.valid? }

    specify '#continuous_value required' do
      expect(observation.errors.include?(:continuous_value)).to be_truthy
    end
  end
end
