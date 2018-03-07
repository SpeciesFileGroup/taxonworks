require 'rails_helper'

describe 'Containables', type: :model, group: :containers do
  let(:containable_class) {TestContainable.new}

  let(:building) { Container::Building.create!(name: 'building') }
  let(:box) { Container::Box.create!(name: 'box', contained_in: building) }
  let(:drawer) { Container::Drawer.create!(name: '42', contained_in: box) }
  let(:envelope) { Container::Envelope.create!(name: 'envelope', contained_in: drawer) }

  let(:slide_box) {Container::SlideBox.create()}
  let(:slide) {Container::Slide.create(container: slide_box, name: 'my slide box')}
  let(:unit_tray) {Container::UnitTray.create(disposition: 'col 1 row 2') }

  context 'associations' do
    specify 'container' do
      expect(containable_class).to respond_to(:container)
    end

    specify 'container can not be set directly' do
      expect {containable_class.container = Container.new}.to raise_error ActiveRecord::HasOneThroughNestedAssociationsAreReadonly
    end

    specify 'container_item' do
      expect(containable_class.container_item = ContainerItem.new).to be_truthy
    end
  end

  specify '#containable?' do
    expect(containable_class.containable?).to eq(true)
  end

  specify '#contained?' do
    expect(containable_class.contained?).to eq(false)
  end

  specify '#enclosing_containers' do
    expect(containable_class.enclosing_containers).to eq([])
  end

  specify '#containable?' do
    expect(containable_class.containable?).to eq(true)
  end

  context 'putting in a container' do
    specify 'with contained_in' do
      containable_class.contained_in = building
      expect(containable_class.save).to be_truthy
      expect(containable_class.container).to eq(building)
    end
  end

  context 'with multiple containers' do
    specify '#enclosing_containers' do
      containable_class.contained_in = envelope
      containable_class.save
      containable_class.reload
      expect(containable_class.enclosing_containers).to eq([envelope, drawer, box, building])
    end

  end
end

class TestContainable < ApplicationRecord
  include FakeTable
  include Shared::Containable
end

