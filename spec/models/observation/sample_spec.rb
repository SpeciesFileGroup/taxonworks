require 'rails_helper'

RSpec.describe Observation::Sample, type: :model, group: :matrix do
  let(:observation) { Observation::Sample.new } 

  context 'validation' do
    before { observation.valid? }

    specify '#sample_n required' do
      expect(observation.errors.include?(:sample_n)).to be_truthy
    end

    specify '#sample_min required' do
      expect(observation.errors.include?(:sample_min)).to be_truthy
    end

    specify '#sample_max required' do
      expect(observation.errors.include?(:sample_max)).to be_truthy
    end

    specify '#sample_median required' do
      expect(observation.errors.include?(:sample_median)).to be_truthy
    end

    specify '#sample_mean required' do
      expect(observation.errors.include?(:sample_mean)).to be_truthy
    end

    specify '#sample_units required' do
      expect(observation.errors.include?(:sample_units)).to be_truthy
    end

    specify '#sample_standard_deviation required' do
      expect(observation.errors.include?(:sample_standard_deviation)).to be_truthy
    end

    specify '#sample_standard_error required' do
      expect(observation.errors.include?(:sample_standard_error)).to be_truthy
    end
  end
end