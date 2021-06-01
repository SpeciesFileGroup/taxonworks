require 'rails_helper'

RSpec.describe Descriptor::Continuous, type: :model, group: [:descriptor, :observation_matrix] do
  let(:descriptor) { Descriptor::Continuous.new }

  let(:otu) { FactoryBot.create(:valid_otu) }

  context 'validation' do
    specify '#default_unit 1' do
      descriptor.valid? 
      expect(descriptor.errors.include?(:default_unit)).to be_falsey
    end

    specify '#default_unit 2' do
      descriptor.default_unit = 'kahugeflugers'
      descriptor.valid? 
      expect(descriptor.errors.include?(:default_unit)).to be_truthy
    end

    specify '#default_unit 3' do
      descriptor.default_unit = 'mm'
      descriptor.valid? 
      expect(descriptor.errors.include?(:default_unit)).to be_falsey
    end
  end

  context 'returning observations' do
    before do
      descriptor.name = 'Head size'
      descriptor.default_unit = 'mm'
      descriptor.save!
    end

    context '#observations' do
      let(:continuous_descriptor) { Descriptor::Continuous.create!(name: 'Head length') }
      let!(:observation1) { Observation::Continuous.create!(otu: otu, descriptor: descriptor, continuous_value: 42, continuous_unit: 'cm' ) }
      let!(:observation2) { Observation::PresenceAbsence.create!(otu: otu, descriptor: FactoryBot.create(:valid_descriptor, type: 'Descriptor::PresenceAbsence'), presence: false, continuous_unit: 'm') }

      specify 'only co-typed observations are returned' do
        expect(descriptor.observations).to contain_exactly(observation1)
      end
    end
  end

end
