require 'spec_helper'

describe ContainerItem do

  let(:container_item) { FactoryGirl.build(:container_item) }

  context "validation" do
    context 'required' do
      before(:each) {
        container_item.valid?
      }
      specify "contained_object" do
        expect(container_item.errors.include?(:contained_object)).to be_truthy
      end

      specify "container" do
        expect(container_item.errors.include?(:container)).to be_truthy
      end
    end
  end

end
