require 'rails_helper'

RSpec.describe Observation::Working, type: :model, group: :observation_matrix do
  let(:observation) { Observation::Working.new }

  specify '#description required' do
    observation.valid?
    expect(observation.errors.include?(:description)).to be_truthy
  end

  specify 'only one per "cell"' do
    o = FactoryBot.create(:valid_observation_working)
    o1 = Observation::Working.new(descriptor: o.descriptor, description: 'foo', observation_object: o.observation_object)
    o1.valid?
    expect(o1.errors.include?(:descriptor_id)).to be_truthy
  end
end
