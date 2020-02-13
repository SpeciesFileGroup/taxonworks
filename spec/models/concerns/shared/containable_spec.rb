require 'rails_helper'

describe 'Containables', type: :model, group: :containers do
  let!(:containable_class) {TestContainable.new}

  let!(:building) { Container::Building.create!(name: 'building') }
  let(:box) { Container::Box.create!(name: 'box', contained_in: building) }
  let(:drawer) { Container::Drawer.create!(name: '42', contained_in: box) }
  let(:envelope) { Container::Envelope.create!(name: 'envelope', contained_in: drawer) }

  let(:slide_box) {Container::SlideBox.create(name: 'my slide box')}
  let(:slide) {Container::Slide.create(contained_in: slide_box, name: 'my slide')}
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

  specify '#contained_siblings 1' do
    expect(containable_class.contained_siblings).to contain_exactly()
  end

  context 'siblings' do
    before do
      slide_box
      slide
    end

    let!(:slide2) { Container::Slide.create!(contained_in: slide_box, name: 'my slide box') }

    specify '#contained_siblings 3' do
      expect(slide.contained_siblings).to contain_exactly(slide2)
    end

    specify '#contained_siblings 4' do
      expect(slide2.contained_siblings).to contain_exactly(slide)
    end
  end

  specify '#contained_siblings 2' do
    slide_box
    slide
    expect(slide.contained_siblings).to contain_exactly()
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

