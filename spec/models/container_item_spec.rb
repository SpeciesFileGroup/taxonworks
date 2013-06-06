require 'spec_helper'

describe ContainerItem do

  let(:container_item) { ContainerItem.new }

  context "validation" do
    specify "containable_id is not nil" do
      container_item.save
      expect(container_item.errors.include?(:containable_id)).to be_true
    end

    specify "containable_type is not nil" do
      container_item.save
      expect(container_item.errors.include?(:containable_type)).to be_true
    end

    specify "container_id is not nil" do
      container_item.save
      expect(container_item.errors.include?(:container_id)).to be_true
    end
  end

end
