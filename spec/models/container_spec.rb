require 'spec_helper'

describe Container do

  let(:container) { FactoryGirl.build(:container) }

  context 'associations' do
    context 'has_many' do
      specify 'collection_objects' do
        expect(container).to respond_to(:collection_objects)
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

  context 'soft validation' do
    specify 'inapropriate parent container' do
      container.type = 'Container::Drawer'
      expect(container.save).to be_true
      container1 = FactoryGirl.build_stubbed(:container, type: 'Container::Cabinet', parent: container)
      container2 = FactoryGirl.build_stubbed(:container, type: 'Container::Pin', parent: container)
      container1.soft_validate(:parent_type)
      container2.soft_validate(:parent_type)
      expect(container1.soft_validations.messages_on(:type).count).to eq(1)
      expect(container2.soft_validations.messages_on(:type).empty?).to be_true
    end
  end

end
