require 'rails_helper'

describe ContainerItem, type: :model, group: :containers do

  let(:container_item) { ContainerItem.new } 

  let(:specimen) { FactoryBot.create(:valid_specimen) }

  let(:container1) { FactoryBot.create(:valid_container, name: 'Top') }
  let(:container2) { FactoryBot.create(:valid_container, name: 'Middle') }

  specify '#create' do
    expect(ContainerItem.create!(
      container_id: container2.id,
      global_entity: specimen.to_global_id.to_s
    )).to be_truthy
  end

  # TODO: move to concern
  specify '#destroy of contained item destroys container item' do
    c = ContainerItem.create!(container_id: container2.id, global_entity: specimen.to_global_id.to_s)  
    specimen.destroy
    expect { c.reload }.to raise_error ActiveRecord::RecordNotFound
  end

  context 'validation' do
    context 'required' do
      before(:each) {
        container_item.valid?
      }

      specify 'contained_object_id' do
        expect(container_item.errors.include?(:contained_object_id)).to be_truthy
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
          container_item.parent = containing_container_item
          container_item.disposition_x = 10
          container_item.disposition_y = 10
          container_item.save!
          c = ContainerItem.new(parent: containing_container_item, contained_object: FactoryBot.create(:valid_specimen), disposition_x: 10, disposition_y: 10)
          expect(c.valid?).to be_falsey
          expect(c.errors.include?(:base)).to be_truthy
        end
      end
    end

    context 'containers' do
      # A parent container     ci1
      #    A child container   ci2
      #       A specimen       ci3 
      
      let(:ci1) { ContainerItem.create!(contained_object: container1) } 
      let(:ci2) { ContainerItem.create!(contained_object: container2, parent: ci1) } 
      let(:ci3) { ContainerItem.new(contained_object: o1) }

      let(:o1) { Specimen.create! }

      specify '#parent is set via parent:' do
        expect(ci2.parent_id).to be_truthy
      end

      specify '#parent is set via #container_id= 1' do
        ci3.update!(container_id: container2.id)
        expect(ci3.parent_id).to be_truthy
      end

      specify '#parent is set via #container_id 2' do
        ci4 = ContainerItem.create!(contained_object: Specimen.create!, container_id: container2.id) 
        expect(ci4.reload.parent_id).to be_truthy
      end

      specify '#parent is set via container_id when container has other specimens' do
        ci3.update!(container_id: container2.id)
        ci4 = ContainerItem.create!(contained_object: Specimen.create!, container_id: container2.id) 
        expect(ci4.parent_id).to be_truthy
      end

      specify '#container is alias for parent.contained_object' do
        ci3.update!(parent: ci2)
        expect(o1.container_item.container.metamorphosize).to eq(container2)
      end

      specify '#container_id can set #container' do
        ci3.update!(container_id: container2.id)
        expect(ci3.container.metamorphosize).to eq(container2)
      end

      specify '#container= can set container' do
        ci3.container = container2
        ci3.save!
        expect(ci3.container.metamorphosize).to eq(container2)
      end

      specify '#contained_object is not sibiling' do
        c = FactoryBot.create(:valid_container)
        a = Specimen.create!
        b = Specimen.create!
        ci1 = ContainerItem.create!(contained_object: a, container_id: c.id)
        expect {ContainerItem.create!(contained_object: c, container_id: c.id)}.to raise_error ActiveRecord::RecordInvalid, 'Validation failed: Contained object is already in a container_item'
      end
    end

    context 'closure tree' do
      let(:c1) { ContainerItem.create(contained_object: container1) }
      let(:c2) { ContainerItem.create(contained_object: container2, parent: c1) }

      specify 'children' do
        expect(c1.children.all).to eq([c2])
      end
    end

    context 'setting contained object by reference to global id' do
      specify '#global_entity=' do
        container_item.global_entity = specimen.to_global_id.to_s
        expect(container_item.contained_object).to eq(specimen)
      end

      specify '#global_entity' do
        container_item.contained_object = specimen 
        expect(container_item.global_entity).to eq(specimen.to_global_id)
      end
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
