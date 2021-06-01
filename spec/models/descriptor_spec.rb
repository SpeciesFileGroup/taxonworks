require 'rails_helper'

RSpec.describe Descriptor, type: :model, group: :observation_matrix do
  let(:descriptor) { Descriptor.new }

  context 'validation' do
    before { descriptor.valid? }

    specify 'type is required' do
      expect(descriptor.errors.include?(:type)).to be_truthy
    end
   
    specify 'name is required' do
      expect(descriptor.errors.include?(:name)).to be_truthy
    end

    specify 'type of "Descriptor" is not valid' do
      descriptor.type = 'Descriptor'
      descriptor.valid?
      expect(descriptor.errors.include?(:type)).to be_truthy
    end

    specify 'valid types include subclasses' do 
      descriptor.type = 'Descriptor::Qualitative'
      descriptor.valid?
      expect(descriptor.errors.include?(:type)).to be_falsey
    end

    specify 'short_name is at least shorter than name if both provided' do
      descriptor.short_name = 'abcd'
      descriptor.name = 'abc'
      descriptor.valid?
      expect(descriptor.errors.include?(:short_name)).to be_truthy
    end

    context 'soft validation' do
      specify 'short means < 12 characters' do
        descriptor.short_name = '1234567890123'
        descriptor.soft_validate
        expect(descriptor.soft_valid?).to be_falsey
        expect(descriptor.soft_validations.messages_on(:short_name).size).to eq(1)
      end

    end

  end

end
