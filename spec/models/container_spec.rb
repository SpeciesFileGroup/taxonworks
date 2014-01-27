require 'spec_helper'

describe Container do

  let(:container) { Container.new }

  context 'associations' do
    context 'has_many' do
      specify "physical_collection_objects" do
        expect(container).to respond_to(:physical_collection_objects)
      end
    end
  end

  context "from awesome_nested_set" do
    specify "root" do
      expect(container).to respond_to(:root)
    end
  end

  context "concerns" do
    it_behaves_like "identifiable"
    it_behaves_like "containable"
  end

end
