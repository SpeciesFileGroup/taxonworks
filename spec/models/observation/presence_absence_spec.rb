require 'rails_helper'

RSpec.describe Observation::PresenceAbsence, type: :model, group: :observation_matrix do
  let(:observation) { Observation::PresenceAbsence.new } 

  context 'validation' do
    before { observation.valid? }

    specify '#presence required' do
      expect(observation.errors.include?(:presence)).to be_truthy
    end
  end
end
