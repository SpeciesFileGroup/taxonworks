require 'rails_helper'

RSpec.describe CharacterState, type: :model, group: :matrix do
  let(:character_state) { CharacterState.new }
  let(:descriptor) { Descriptor::Qualitative.create(name: 'Head color') }

  context 'validation' do
    before {character_state.valid?}

    specify '#name is required' do
      expect(character_state.errors.include?(:name)).to be_truthy
    end

    specify '#label is required' do
      expect(character_state.errors.include?(:label)).to be_truthy
    end

    specify '#descriptor is required' do
      expect(character_state.errors.include?(:descriptor)).to be_truthy
    end
  end

  context '#descriptor.type' do
    before do 
      character_state.descriptor = Descriptor.new 
      character_state.valid?
    end

    specify 'is invalid if not Descriptor::Qualitative' do
      expect(character_state.errors.include?(:descriptor)).to be_truthy
    end
  end

  context 'a valid character state' do
    before do
      character_state.update(descriptor: descriptor, name: 'blue', label: '0') 
    end 

    specify 'has descriptor, name, and label' do
      expect(descriptor.valid?).to be_truthy
    end
  end

  context 'uniqueness within descriptor' do
    before { CharacterState.create(descriptor: descriptor, name: 'blue', label: '0')  }
    context 'name is unique' do
      before do 
        character_state.update(descriptor:descriptor, name: 'blue', label: '1')
      end 

      specify 'and can not be reused' do
        expect(character_state.valid?).to be_falsey
        expect(character_state.errors.include?(:name)).to be_truthy
      end
    end

    context 'label is unique' do
      before do 
        character_state.update(descriptor:descriptor, name: 'blue', label: '0')
      end 

      specify 'and can not be reused' do
        expect(character_state.valid?).to be_falsey
        expect(character_state.errors.include?(:label)).to be_truthy
      end
    end
  end

  context 'concerns' do
    it_behaves_like 'citable'
    it_behaves_like 'identifiable'
    it_behaves_like 'notable'
    it_behaves_like 'taggable'
    it_behaves_like 'is_data'
    it_behaves_like 'documentation'
    # confidence, depiction
  end



end
