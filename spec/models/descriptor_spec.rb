require 'rails_helper'

RSpec.describe Descriptor, type: :model do
  let(:descriptor) {Descriptor.new}

  context 'validation' do
    context 'fails when not given' do
      before(:each){
        descriptor.valid?
      }

      specify 'descriptor_id' do
        expect(descriptor.errors.include?(:descriptor_id)).to be_truthy
      end
    end

    context 'passes when given' do
      specify 'descriptor_id' do
        descriptor.descriptor_id = 1;
        expect(descriptor.valid?).to be_truthy
      end
    end
  end
end
