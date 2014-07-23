require 'rails_helper'

describe Container, :type => :model do

  let(:container) { FactoryGirl.build(:container) }

  context 'associations' do
    context 'has_many' do
      specify 'container_items' do
        expect(container).to respond_to(:container_items)
      end

      specify 'collection_objects' do
        expect(container).to respond_to(:collection_objects)
      end

      specify 'collection_profiles' do
        expect(container).to respond_to(:collection_profiles)
      end

      specify 'type' do
        expect(container).to respond_to(:type)
      end
    end
  end

  context 'containable items' do
   before(:each) {
     container.type_class = Container::Virtual
   }

   specify 'add items to an unsaved container' do
     container.collection_objects << (FactoryGirl.create(:valid_specimen))
     expect(container.save).to be_truthy
     expect(container.container_items.count).to eq(1)
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
      expect(container.valid?).to be_falsey
      container.type = 'Container::Drawer'
      expect(container.valid?).to be_truthy
    end
  end

  context 'soft validation' do
    specify 'inapropriate parent container' do
      container.type = 'Container::Drawer'
      expect(container.save).to be_truthy
      container1 = FactoryGirl.build_stubbed(:container, type: 'Container::Cabinet', parent: container)
      container2 = FactoryGirl.build_stubbed(:container, type: 'Container::Pin', parent: container)
      container1.soft_validate(:parent_type)
      container2.soft_validate(:parent_type)
      expect(container1.soft_validations.messages_on(:type).count).to eq(1)
      expect(container2.soft_validations.messages_on(:type).empty?).to be_truthy
    end
  end

end
