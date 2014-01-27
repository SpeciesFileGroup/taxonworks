require 'spec_helper'

describe PreparationType do

  let(:preparation_type) {PreparationType.new}

  context 'associations' do
    context 'has_many' do
      specify 'collection_objects' do
        expect(preparation_type).to respond_to(:collection_objects)
      end
    end
  end


  context "validation" do
    before do
      preparation_type.valid?
      specify 'name is required' do
        expect(preparation_type.errors.include?(:name)).to be_true
      end
    end

  end
end
