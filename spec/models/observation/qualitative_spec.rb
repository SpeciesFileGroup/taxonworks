require 'rails_helper'

RSpec.describe Observation::Qualitative, type: :model, group: :observation_matrix do
  let(:observation) { Observation::Qualitative.new }
  let(:descriptor) { FactoryBot.create(:valid_descriptor_qualitative) }
  let(:otu) { FactoryBot.create(:valid_otu) }

  context 'validation' do
    before { observation.valid? }
    specify '#character_state_id required' do
      expect(observation.errors.include?(:character_state_id)).to be_truthy
    end

    context 'duplication' do
      let!(:cs) { FactoryBot.create(:valid_character_state, descriptor: descriptor) }
      let!(:o1) { FactoryBot.create(:valid_observation, character_state_id: cs.id, descriptor: descriptor, observation_object: otu, type: 'Observation::Qualitative') }

      specify 'are prevented 1' do
        o = Observation.create(observation_object: otu, descriptor: descriptor, character_state: cs, type: 'Observation::Qualitative')
        expect(o.errors.include?(:descriptor_id)).to be_truthy
      end

      specify 'are prevented 2' do
        o = Observation.create(observation_object: otu, descriptor: descriptor, character_state_id: cs.id, type: 'Observation::Qualitative')
        expect(o.errors.include?(:descriptor_id)).to be_truthy
      end
    end
  end
end
