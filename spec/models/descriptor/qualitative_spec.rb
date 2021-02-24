require 'rails_helper'

RSpec.describe Descriptor::Qualitative, type: :model, group: [:descriptor, :observation_matrix] do
  let(:descriptor) { Descriptor::Qualitative.new }

  specify '#character_states' do
    expect(descriptor.character_states << CharacterState.new).to be_truthy
  end

  specify '#character_states_attributes 1' do
    descriptor.name = 'Head color'
    descriptor.character_states_attributes = [ {name: 'Blue', label: '0'}, {name: 'Red', label: '1'} ] 
    descriptor.save!
    expect(descriptor.character_states.count).to eq(2)
  end

end
