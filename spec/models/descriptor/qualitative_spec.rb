require 'rails_helper'

RSpec.describe Descriptor::Qualitative, type: :model, group: :matrix do
  let(:descriptor) { Descriptor::Qualitative.new }

  specify '#character_states' do
    expect(descriptor.character_states << CharacterState.new).to be_truthy
  end

end
