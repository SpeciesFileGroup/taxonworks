require 'rails_helper'

RSpec.describe Observation::Continuous, type: :model, group: :observation_matrix do
  let(:observation) { Observation::Continuous.new } 

  let(:otu) { FactoryBot.create(:valid_otu) }

  specify '#continuous_value required' do
    observation.valid?
    expect(observation.errors.include?(:continuous_value)).to be_truthy
  end

  specify 'units_compatible 1' do
    observation.descriptor = Descriptor::Continuous.new(default_unit: 'm')
    observation.continuous_unit = 'kg'
    observation.valid?
    expect(observation.errors.include?(:continuous_unit)).to be_truthy
  end

  specify 'units_compatible 2' do
    observation.descriptor = Descriptor::Continuous.new(default_unit:  'm')
    observation.continuous_unit = 'ft'
    observation.valid?
    expect(observation.errors.include?(:continuous_unit)).to be_falsey
  end

  specify '#unit' do
    d = Descriptor::Continuous.create!(name: 'Setae', default_unit: 'count')
    o1 = Observation::Continuous.create!(otu: otu, descriptor: d, continuous_value: 1, continuous_unit: 'count' )
    expect(o1.unit).to be_a(::RubyUnits::Unit)
  end

  context 'units, operators' do
    specify '"speed" +' do
      d = Descriptor::Continuous.create!(name: 'Speed', default_unit: 'm/s')
      o1 = Observation::Continuous.create!(otu: otu, descriptor: d, continuous_value: 1, continuous_unit: 'km/h' )
      o2 = Observation::Continuous.create!(otu: otu, descriptor: d, continuous_value: 2, continuous_unit: 'm/s' )
      expect((o1 + o2).to_s).to eq('2.27778 m/s')
    end

    specify 'count -' do
      d = Descriptor::Continuous.create!(name: 'Setae', default_unit: 'count')
      o1 = Observation::Continuous.create!(otu: otu, descriptor: d, continuous_value: 1, continuous_unit: 'count' )
      o2 = Observation::Continuous.create!(otu: otu, descriptor: d, continuous_value: 2, continuous_unit: 'count' )
      expect(o1 - o2).to eq(-1)
    end
    
    specify 'count +' do
      d = Descriptor::Continuous.create!(name: 'Setae', default_unit: 'count')
      o1 = Observation::Continuous.create!(otu: otu, descriptor: d, continuous_value: 1, continuous_unit: 'count' )
      o2 = Observation::Continuous.create!(otu: otu, descriptor: d, continuous_value: 2, continuous_unit: 'count' )
      expect(o1 + o2).to eq(3)
    end

    specify '#converted_value' do
      d = Descriptor::Continuous.create!(name: 'Speed', default_unit: 'm/s')
      o1 = Observation::Continuous.create!(otu: otu, descriptor: d, continuous_value: 1, continuous_unit: 'km/h' )
      expect(o1.converted_value).to eq(0.2777777777777778)
    end

  end
end
