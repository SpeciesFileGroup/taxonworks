require 'rails_helper'

RSpec.describe Observation::PresenceAbsence, type: :model, group: :observation_matrix do
  let(:observation) { Observation::PresenceAbsence.new } 

  context 'validation' do
    before { observation.valid? }

    specify '#presence required' do
      expect(observation.errors.include?(:presence)).to be_truthy
    end

    # TODO: !! Specification is not correct.  Technically 2 per cell are allowed.  See model for notes.
    specify 'only one per "cell"' do
      o = FactoryBot.create(:valid_observation_presence_absence)
      o1 = Observation::PresenceAbsence.new(descriptor: o.descriptor, presence: true, observation_object: o.observation_object)
      o1.valid?
      expect(o1.errors.include?(:descriptor_id)).to be_truthy
    end

  end
end
