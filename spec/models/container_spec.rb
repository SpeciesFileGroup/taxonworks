require 'rails_helper'

describe Container, type: :model, group: :containers do
  let(:container) { Container.new }
  let(:objects) { [Specimen.create, Specimen.create] }

  context 'validation' do
    specify 'type is required' do
      expect(container.valid?).to be_falsey
    end

    specify 'type can not be an invalid type' do
      container.type = 'aaa'
      expect { container.save }.to raise_error(ActiveRecord::SubclassNotFound)
    end

    specify 'invalid type can not be assigned on #new' do
      expect { Container.new(type: 'Can::Soda') }.to raise_error(ActiveRecord::SubclassNotFound)
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

    specify 'defaults to Container::Virtual' do
      expect(c.class).to eq(Container::Virtual)
    end

    specify 'returns false if objects are not saved' do
      expect(Container.containerize([Specimen.new])).to be_falsey
    end
  end

  context 'container items' do
    let(:c) { FactoryBot.create(:valid_container) }

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
      before { container.size_x = 3 }

      specify '#size (one dimensional)' do
        expect(container.size).to eq(3)
      end

      context 'y set' do
        before { container.size_y = 3 }

        specify '#size (two dimensional)' do
          expect(container.size).to eq(9)
        end

        context 'z set' do
          before { container.size_z = 3 }

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
        container.type   = 'Container::Virtual'
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

  context 'a complex top-down stack of containers and other containable objects' do
    # build container hierarchy
    let(:site) { Container::Site.create(name: 'INHS Test Site') }
    let(:building) { Container::Building.create(name: 'Forbes', contained_in: site) }
    let(:room) { Container::Room.create(name: 'Room 2064', contained_in: building) }
    let(:rack) { Container::VialRack.create(name: 'credenza', contained_in: room) }
    let(:vial) { Container::Vial.create(name: 'water bottle', contained_in: rack) }

    # a pair of collection objects for one container
    let!(:specimens) { [Specimen.create(contained_in: vial), Specimen.create(contained_in: vial)] }


    # a single collection objects for another container
    let(:specimen) { FactoryBot.create(:valid_specimen) }

    let(:add_specimen) { rack.add_container_items([specimen]) }

    specify 'finding some collection objects somewhere in the stack' do
      expect(add_specimen).to be_truthy
      expect(site.collection_objects).to contain_exactly(specimen,
                                                         specimens[0],
                                                         specimens[1])
    end
  end

  context 'a complex bottom-up stack of containers and other containable objects' do
    # build container hierarchy
    let(:vial) { Container.containerize(specimens, Container::Vial) }
    let(:rack) { Container.containerize([vial], Container::VialRack) }
    let(:add_specimen) { rack.add_container_items([specimen]) }
    let(:room) { Container.containerize([rack], Container::Room) }
    let(:building) { Container.containerize([room], Container::Building) }
    let(:site) { Container.containerize([building], Container::Site) }

    # a pair of collection objects for one container
    let(:specimens) { [Specimen.create, Specimen.create] }
    # a single collection objects for another container
    let(:specimen) { FactoryBot.create(:valid_specimen) }

    specify 'finding some collection objects somewhere in the stack' do
      expect(site.save).to be_truthy
      expect(add_specimen).to be_truthy
      expect(site.collection_objects).to contain_exactly(specimen,
                                                         specimens[0],
                                                         specimens[1])
    end
  end

  context 'asserted_percent_empty' do
    let(:c) { Container.new(type: 'Container::Drawer') }

    specify 'is valid when nil' do
      c.asserted_percent_empty = nil
      expect(c.valid?).to be_truthy
    end

    specify 'is valid at 0.0' do
      c.asserted_percent_empty = 0.0
      expect(c.valid?).to be_truthy
    end

    specify 'is valid at 100.0' do
      c.asserted_percent_empty = 100.0
      expect(c.valid?).to be_truthy
    end

    specify 'is valid at a value between 0 and 100' do
      c.asserted_percent_empty = 42.5
      expect(c.valid?).to be_truthy
    end

    specify 'is invalid when negative' do
      c.asserted_percent_empty = -1.0
      expect(c.valid?).to be_falsey
      expect(c.errors[:asserted_percent_empty]).to be_present
    end

    specify 'is invalid when greater than 100' do
      c.asserted_percent_empty = 100.1
      expect(c.valid?).to be_falsey
      expect(c.errors[:asserted_percent_empty]).to be_present
    end
  end

  context 'asserted_percent_earmarked' do
    let(:c) { Container.new(type: 'Container::Drawer') }

    specify 'is valid when nil' do
      c.asserted_percent_earmarked = nil
      expect(c.valid?).to be_truthy
    end

    specify 'is valid at 0.0' do
      c.asserted_percent_earmarked = 0.0
      c.asserted_percent_empty     = 0.0
      expect(c.valid?).to be_truthy
    end

    specify 'is valid at 100.0 when empty is also 100.0' do
      c.asserted_percent_earmarked = 100.0
      c.asserted_percent_empty     = 100.0
      expect(c.valid?).to be_truthy
    end

    specify 'is invalid when negative' do
      c.asserted_percent_earmarked = -1.0
      c.asserted_percent_empty     = 50.0
      expect(c.valid?).to be_falsey
      expect(c.errors[:asserted_percent_earmarked]).to be_present
    end

    specify 'is invalid when greater than 100' do
      c.asserted_percent_earmarked = 101.0
      c.asserted_percent_empty     = 100.0
      expect(c.valid?).to be_falsey
      expect(c.errors[:asserted_percent_earmarked]).to be_present
    end

    specify 'is invalid when empty is nil' do
      c.asserted_percent_earmarked = 25.0
      c.asserted_percent_empty     = nil
      expect(c.valid?).to be_falsey
      expect(c.errors[:asserted_percent_empty]).to be_present
    end

    specify 'is invalid when empty is less than earmarked' do
      c.asserted_percent_earmarked = 50.0
      c.asserted_percent_empty     = 49.9
      expect(c.valid?).to be_falsey
      expect(c.errors[:asserted_percent_empty]).to be_present
    end

    specify 'is valid when empty equals earmarked' do
      c.asserted_percent_earmarked = 30.0
      c.asserted_percent_empty     = 30.0
      expect(c.valid?).to be_truthy
    end

    specify 'is valid when empty is greater than earmarked' do
      c.asserted_percent_earmarked = 30.0
      c.asserted_percent_empty     = 60.0
      expect(c.valid?).to be_truthy
    end
  end

  context 'size_does_not_exclude_placed_items' do
    let(:cabinet) { Container::Cabinet.create!(size_x: 5, size_y: 5, size_z: 3) }
    let(:drawer)  { Container::Drawer.create! }

    before do
      cabinet.add_container_items([drawer])
      ContainerItem.find_by(contained_object: drawer)
        .update!(disposition_x: 3, disposition_y: 3, disposition_z: 2)
    end

    context 'x axis' do
      specify 'can shrink x when no item exceeds the new boundary' do
        cabinet.size_x = 4
        expect(cabinet.valid?).to be_truthy
      end

      specify 'cannot shrink x to exclude a placed item' do
        cabinet.size_x = 2
        expect(cabinet.valid?).to be_falsey
      end

      specify 'can grow x' do
        cabinet.size_x = 10
        expect(cabinet.valid?).to be_truthy
      end
    end

    context 'y axis' do
      specify 'can shrink y when no item exceeds the new boundary' do
        cabinet.size_y = 4
        expect(cabinet.valid?).to be_truthy
      end

      specify 'cannot shrink y to exclude a placed item' do
        cabinet.size_y = 2
        expect(cabinet.valid?).to be_falsey
      end

      specify 'can grow y' do
        cabinet.size_y = 10
        expect(cabinet.valid?).to be_truthy
      end
    end

    context 'z axis' do
      specify 'can shrink z when no item exceeds the new boundary' do
        cabinet.size_z = 2
        expect(cabinet.valid?).to be_truthy
      end

      specify 'cannot shrink z to exclude a placed item' do
        cabinet.size_z = 1
        expect(cabinet.valid?).to be_falsey
      end

      specify 'can grow z' do
        cabinet.size_z = 10
        expect(cabinet.valid?).to be_truthy
      end
    end

    specify 'adds a :base error with the expected message' do
      cabinet.size_x = 2
      cabinet.valid?
      expect(cabinet.errors[:base]).to include('Resize would impact placed containers')
    end
  end

  context 'concerns' do
    it_behaves_like 'containable'
    it_behaves_like 'identifiable'
    it_behaves_like 'taggable'
    it_behaves_like 'is_data'
  end

  context '.scaffold' do
    let(:building) { FactoryBot.create(:valid_container, type: 'Container::Building', name: 'Main Building') }

    let(:valid_params) do
      { building_id: building.id, cabinet_type: 'Container::Cabinet::Cornell', rooms: 2, cabinets: 3, drawers: 4 }
    end

    specify 'returns an array of created rooms on success' do
      result = Container.scaffold(valid_params)
      expect(result).to be_an(Array)
      expect(result.length).to eq(2)
      expect(result).to all(be_a(Container::Room))
    end

    specify 'creates the correct number of rooms under the building' do
      Container.scaffold(valid_params)
      ci = ContainerItem.find_by(contained_object: building)
      expect(ci.children.count).to eq(2)
    end

    specify 'each room has the correct number of cabinets' do
      Container.scaffold(valid_params)
      ci_building = ContainerItem.find_by(contained_object: building)
      ci_building.children.each do |ci_room|
        expect(ci_room.children.count).to eq(3)
        expect(ci_room.children.map { |c| c.contained_object.type }).to all(eq('Container::Cabinet::Cornell'))
      end
    end

    specify 'each cabinet has the correct number of drawers' do
      Container.scaffold(valid_params)
      ci_building = ContainerItem.find_by(contained_object: building)
      ci_building.children.each do |ci_room|
        ci_room.children.each do |ci_cabinet|
          expect(ci_cabinet.children.count).to eq(4)
          expect(ci_cabinet.children.map { |c| c.contained_object.type }).to all(eq('Container::Drawer::Cornell'))
        end
      end
    end

    specify 'works with Container::Cabinet::CalAcademy cabinet type' do
      result = Container.scaffold(valid_params.merge(cabinet_type: 'Container::Cabinet::CalAcademy', rooms: 1, cabinets: 1, drawers: 2))
      expect(result).to be_an(Array)
      ci_building = ContainerItem.find_by(contained_object: building)
      ci_room = ci_building.children.first
      ci_cabinet = ci_room.children.first
      expect(ci_cabinet.contained_object.type).to eq('Container::Cabinet::CalAcademy')
      expect(ci_cabinet.children.map { |c| c.contained_object.type }).to all(eq('Container::Drawer::CalAcademy'))
    end

    specify 'returns false when no cabinet_type is given and base Cabinet has no matching Drawer' do
      expect(Container.scaffold(valid_params.merge(cabinet_type: 'Container::Cabinet::Unknown'))).to be_falsey
    end

    specify 'returns false when rooms is zero' do
      expect(Container.scaffold(valid_params.merge(rooms: 0))).to be_falsey
    end

    specify 'returns false when building_id is invalid' do
      expect(Container.scaffold(valid_params.merge(building_id: 0))).to be_falsey
    end

    specify 'rolls back all changes when an error occurs mid-transaction' do
      allow(ContainerItem).to receive(:create!).and_call_original
      call_count = 0
      allow(Container::Room).to receive(:create!) do
        call_count += 1
        raise ActiveRecord::RecordInvalid.new(Container.new) if call_count > 1
        Container::Room.new.tap { |r| r.name = 'Room 1'; r.save! }
      end

      Container.scaffold(valid_params)
      expect(ContainerItem.find_by(contained_object: building)).to be_nil
    end
  end

end
