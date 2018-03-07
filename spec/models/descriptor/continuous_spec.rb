require 'rails_helper'

RSpec.describe Descriptor::Continuous, type: :model, group: :matrix do
  let(:descriptor) { Descriptor::Continuous.new }

  let(:otu) { FactoryBot.create(:valid_otu) }

  context 'returning observations' do
    before do
      descriptor.name = 'Head presence'
      descriptor.save!
    end

    context '#observations' do
      let(:continuous_descriptor) { Descriptor::Continuous.create!(name: 'Head length') }
      let!(:observation1) { Observation::Continuous.create!(otu: otu, descriptor: descriptor, continuous_value: 42) }
      let!(:observation2) { Observation::PresenceAbsence.create!(otu: otu, descriptor: continuous_descriptor, presence: false) }

      specify 'only co-typed observations are returned' do
        expect(descriptor.observations).to contain_exactly(observation1)
      end
    end

  end
end
