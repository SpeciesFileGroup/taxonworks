require 'rails_helper'

describe ContainerLabel, :type => :model do
  let(:container_label) {ContainerLabel.new}

  context 'associations' do
    specify 'container' do
      expect(container_label.container = Container.new()).to be_truthy
    end
  end

  context 'validation' do
    before { container_label.valid? }
    
    specify 'label is required' do
      expect(container_label.errors.include?(:label)).to be_truthy 
    end

    specify 'container is required' do
      expect(container_label.errors.include?(:container)).to be_truthy 
    end



  end


end
