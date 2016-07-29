require 'rails_helper'

describe Container, type: :model, group: :containers do
  let(:container) { Container.new }
  let(:objects) {  [Specimen.create, Specimen.create] }

  context 'validation' do
    specify 'type is required' do
      expect(container.valid?).to be_falsey
    end

    specify 'type can not be an invalid type' do
      container.type = 'aaa'
      expect {container.save}.to raise_error(ActiveRecord::SubclassNotFound)
    end

    specify 'invalid type can not be assigned on #new' do
      expect {Container.new(type: 'aaa')}.to raise_error(ActiveRecord::SubclassNotFound)
    end

    specify 'type can be a valid type' do
      container.type = 'Container::Drawer'
      expect(container.valid?).to be_truthy
    end

    context 'with contained items' do
      before {
        container.type = 'Container::Virtual'
        container.save!
        container.add_container_items(objects)
      }

      specify 'can not be destroyed' do 
        expect(container.destroy).to be_falsey
      end
    end
  end

  context 'associations' do
    context 'has_many' do
      specify 'collection_profiles' do
        expect(container.collection_profiles << CollectionProfile.new).to be_truthy
      end
    end
  end

  context '.containerize' do
    let(:c) { Container.containerize(objects) }

    specify 'returns a saved container' do
      expect(c.id).to be_truthy 
    end

    specify 'defaults to Container::Virtual'  do
      expect(c.class).to eq(Container::Virtual)
    end

    specify 'returns false if objects are not saved' do
      expect(Container.containerize([Specimen.new])).to be_falsey
    end
  end

  context 'container items' do
    let(:c) { FactoryGirl.create(:valid_container) }

    specify '#container_items' do
      expect(container).to respond_to(:container_items)
    end

    specify '#collection_objects' do
      expect(container).to respond_to(:collection_objects)
    end

    specify '#add_container_items' do
      expect(c.add_container_items(objects)).to be_truthy
    end

    specify '#add_container_items fails on container.new_record?' do
      new_container = Container.new
      expect(new_container.add_container_items(objects)).to be_falsey
    end

    context 'when added to a container' do
      before { 
        c.add_container_items(objects)
      }

      specify '#container_items' do
        expect(c.container_items.count).to eq(2)
      end

      specify '#contained_objects' do
        expect(c.contained_objects.count).to eq(2)
      end
    end
  end

  context 'size' do
    context 'x set' do
      before {container.size_x = 3}

      specify '#size (one dimensional)' do
        expect(container.size).to eq(3)
      end

      context 'y set' do
        before {container.size_y = 3}

        specify '#size (two dimensional)' do
          expect(container.size).to eq(9)
        end

        context 'z set' do
          before {container.size_z = 3}

          specify '#size (three dimensional)' do
            expect(container.size).to eq(27)
          end
        end
      end
    end

    context 'filling a container' do
      before {
        container.size_x = 3
        container.size_y = 3
        container.type = 'Container::Virtual'
        container.save!
        container.add_container_items(objects)
      }

      specify '#is_full?' do
        expect(container.is_full?).to be_falsey 
      end

      specify '#is_empty?' do
        expect(container.is_empty?).to be_falsey 
      end

      specify '#available_space' do
        expect(container.available_space).to eq(7)
      end
    end
  end

  context 'concerns' do
    it_behaves_like 'containable'
    it_behaves_like 'identifiable'
    it_behaves_like 'taggable'
    it_behaves_like 'is_data'
  end

end
