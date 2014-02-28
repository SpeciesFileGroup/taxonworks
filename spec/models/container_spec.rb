require 'spec_helper'

describe Container do

  let(:container) { FactoryGirl.build(:container) }

  context 'associations' do
    context 'has_many' do
      specify 'physical_collection_objects' do
        expect(container).to respond_to(:physical_collection_objects)
      end
      specify 'type' do
        expect(container).to respond_to(:type)
      end
    end
  end

  context 'from awesome_nested_set' do
    specify 'root' do
      expect(container).to respond_to(:root)
    end
  end

  context 'validation' do
    specify 'type' do
      container.type = 'aaa'
      expect(container.valid?).to be_false
      container.type = 'Container::Drawer'
      expect(container.valid?).to be_true
    end
  end

end
