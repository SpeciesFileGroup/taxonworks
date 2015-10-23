require 'rails_helper'

describe Container, :type => :model do
  let(:container) { Container.new }

  context 'validation' do
    specify 'type is required' do
      expect(container.valid?).to be_falsey
    end

    specify 'type can not be an invalid type' do
      container.type = 'aaa'
      expect {container.save}.to raise_error(ActiveRecord::SubclassNotFound)
    end

    specify 'type can be a valid type' do
      container.type = 'Container::Drawer'
      expect(container.valid?).to be_truthy
    end
  end

  context 'associations' do
    context 'has_many' do
      specify 'container_items' do
        expect(container).to respond_to(:container_items)
      end

      specify 'collection_objects' do
        expect(container.collection_objects << CollectionObject.new).to be_truthy
      end

      specify 'collection_profiles' do
        expect(container.collection_profiles << CollectionProfile.new).to be_truthy
      end
    end
  end

  context '.containerize()' do
    let(:objects) {  [Specimen.create, Specimen.create] }
    let(:c) {  Container.containerize(objects) } 

    specify 'defaults to Container::Virtual'  do
      expect(c.class).to eq(Container::Virtual) 
    end

    specify 'builds container items' do
      # size - in memory
      expect(c.container_items.size).to eq(2) 
    end

    specify 'is not saved by default' do
      expect(c.new_record?).to be_truthy
    end

    specify 'can be saved' do
      expect(c.save).to be_truthy
    end

    specify 'when saved saves container objects' do
      c.save
      expect(c.container_items.count).to eq(2)
    end 
  end

  context 'containable items' do
    before(:each) {
      container.type = 'Container::Virtual'
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

  context 'concerns' do
    it_behaves_like 'containable'
    it_behaves_like 'identifiable'
    it_behaves_like 'taggable'
    it_behaves_like 'is_data'
  end

end
