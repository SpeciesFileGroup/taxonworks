require 'rails_helper'

describe ContainerItem, type: :model, group: :containers do

  let(:container_item) { FactoryBot.build(:container_item) } # Specimen

  let(:specimen) { FactoryBot.create(:valid_specimen) }

  let(:container1) { FactoryBot.create(:valid_container, name: 'Top') }
  let(:container2) { FactoryBot.create(:valid_container, name: 'Middle') }

  context 'validation' do
    context 'required' do
      before(:each) {
        container_item.valid?
      }

      specify 'contained_object' do
        expect(container_item.errors.include?(:contained_object)).to be_truthy
      end
    end

    context '#parent_id' do
      let(:c) { ContainerItem.new }

      specify '#parent (id) is not required for container objects' do
        c.contained_object = container1
        expect(c.save).to be_truthy
      end

      specify '#parent is required for non-container objects' do
        c.contained_object = specimen
        expect(c.save).to be_falsey
        expect(c.errors.include?(:parent_id)).to be_truthy
      end

      context 'container_items contained_objects ' do
        let!(:c1) { ContainerItem.create(contained_object: container1) }
        let(:c2) { ContainerItem.new(contained_object: container1) }

        specify 'must only be referenced in a single container_item' do
          expect(c2.valid?).to be_falsey
          expect(c2.errors.include?(:contained_object)).to be_truthy
        end
      end

      context 'position' do

        let!(:containing_container_item) { ContainerItem.create(contained_object: container1) }
        before {
          container_item.contained_object = FactoryBot.create(:valid_specimen)
          container1.update(size_x: 10, size_y: 10, size_z: 10)
        }

        specify 'is not restricted for undefined container sizes' do
          container_item.parent = containing_container_item
          container_item.update(disposition_x: 10, disposition_y: 10)
          expect(container_item.valid?).to be_truthy
        end

        %w{x y z}.each do |coord|
          specify "#disposition_#{coord} must be in range if container size" do
            container_item.parent = containing_container_item
            container_item.send("disposition_#{coord}=", 11)
            expect(container_item.valid?).to be_falsey
            expect(container_item.errors.include?("disposition_#{coord}".to_sym)).to be_truthy
          end
        end

        specify 'is not replicated' do
          container_item.parent        = containing_container_item
          container_item.disposition_x = 10
          container_item.disposition_y = 10
          container_item.save!
          c = ContainerItem.new(parent: containing_container_item, contained_object: FactoryBot.create(:valid_specimen), disposition_x: 10, disposition_y: 10)
          expect(c.valid?).to be_falsey
          expect(c.errors.include?(:base)).to be_truthy
        end

      end
    end

    context '#container' do
      let(:c1) { ContainerItem.create(contained_object: container1) }
      let(:c2) { ContainerItem.create(contained_object: container1, parent: c1) }

      specify 'is defined by #parent' do
        expect(c2.container.metamorphosize).to eq(c1.contained_object)
      end

      specify 'can be set with #container=' do
        c1.container = container2
        expect(c1.container.metamorphosize).to eq(container2)
      end
    end

    context 'closure tree' do
      let(:c1) { ContainerItem.create(contained_object: container1) }
      let(:c2) { ContainerItem.create(contained_object: container2, parent: c1) }
    end

    context '#global_entity' do

    end

    context 'scopes' do
      let!(:c1) { ContainerItem.create(contained_object: container1) }
      let!(:c2) { ContainerItem.create(contained_object: container2, parent: c1) }
      let!(:c3) { ContainerItem.create(contained_object: specimen, parent: c1) }

      specify '.containers' do
        expect(container1.container_items.containers.to_a).to contain_exactly(c2)
      end

      specify '.not_containers' do
        expect(container1.container_items.not_containers.to_a).to contain_exactly(c3)
      end

      specify '.containing_collection_objects' do
        expect(container1.container_items.containing_collection_objects.to_a).to contain_exactly(c3)
      end
    end

  end

  context 'concerns' do
    it_behaves_like 'is_data'
  end

end
