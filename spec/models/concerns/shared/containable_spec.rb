require 'rails_helper'

describe 'Containables', :type => :model do
  let(:containable_class) { TestContainable.new } 

  let(:building) { Container::Building.create!(name: 'building', parent: nil) }
  let(:box) { Container::Box.create!(name: 'box', parent: building) }
  let(:drawer) { Container::Drawer.create!(name: '42', parent: box) }
  let(:envelope) { Container::Envelope.create!(name: 'envelope', parent: drawer) }
  
  let(:slide_box) {Container::SlideBox.create()}
  let(:slide) {Container::Slide.create(parent: slide_box, name: 'my slide box')}
  let(:unit_tray) {Container::UnitTray.create(disposition: 'col 1 row 2') }


  context "associations" do
    specify "container" do
      expect(containable_class.container = Container.new).to be_truthy 
    end

    specify "container_item" do
      expect(containable_class.container_item = ContainerItem.new).to be_truthy 
    end
  end 

  specify "#contained?" do
    expect(containable_class.contained?).to eq(false)
  end

  context "putting in a container" do
    specify "with =" do
      expect(containable_class.container = envelope).to be_truthy
      containable_class.save!
      expect(containable_class.container_item.id).to_not be(nil)
    end
    
  end

  context 'with multiple containers' do
    specify '#all_containers' do
      containable_class.container = envelope
      expect(containable_class.all_containers).to eq([building, box, drawer, envelope])
    end

    specify '#location with named containers' do
      containable_class.container = envelope
      expect(containable_class.location).to eq('building; box; 42; envelope')
    end

    specify '#location with unamed containers' do 
      containable_class.container = slide_box
      expect(containable_class.location).to eq('slide box') 
    end

    specify '#location with container with location' do 
      containable_class.container = unit_tray
      expect(containable_class.location).to eq('unit tray [col 1 row 2]') 
    end
  end
end

class TestContainable < ActiveRecord::Base
  include FakeTable
  include Shared::Containable
end

