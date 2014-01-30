require 'spec_helper'

describe ContainerItem do

  let(:container_item) { FactoryGirl.build(:container_item) }

  context "validation" do
    context 'required' do
      before(:each) {
        container_item.valid?
      }
      specify "contained_object_id" do
        expect(container_item.errors.include?(:contained_object_id)).to be_true
      end

      specify "contained_object_type" do
        expect(container_item.errors.include?(:contained_object_type)).to be_true
      end

      specify "container_id" do
        expect(container_item.errors.include?(:container_id)).to be_true
      end
    end
  end

end
