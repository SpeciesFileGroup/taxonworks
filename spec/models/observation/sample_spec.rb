require 'rails_helper'

RSpec.describe Observation::Sample, type: :model, group: :observation_matrix do
  let(:observation) { Observation::Sample.new } 

  context 'validation' do
    before { observation.valid? }

    specify '#sample_min required' do
      expect(observation.errors.include?(:sample_min)).to be_truthy
    end

  end
end
