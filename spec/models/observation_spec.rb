require 'rails_helper'

RSpec.describe Observation, type: :model, group: :matrix do
  let(:observation) { Observation.new } 

  context 'validation' do
    before { observation.valid? }

    specify '#description required' do
      expect(observation.errors.include?(:descriptor)).to be_truthy
    end

    specify 'one of #otu or #collection_object is required' do
      expect(observation.errors.include?(:base)).to be_truthy
    end
  end
end
