require 'spec_helper'

describe ContainerType do

  let(:container_type) { ContainerType.new }

  context "validation" do
    context "required / not nil properties" do
      before do
        container_type.save
      end
      specify "name not nil" do
        expect(container_type.errors.include?(:name)).to be_true
      end 
    end
  end

end
