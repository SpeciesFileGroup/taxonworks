require 'spec_helper'

describe CollectionObject do

  let(:collection_object) {CollectionObject.new}

  context 'associations' do
    context 'belongs_to' do
      specify 'preparation_type' do
        expect(collection_object).to respond_to(:preparation_type)
      end

      specify 'repository' do
        expect(collection_object).to respond_to(:repository)
      end


    end
  end

  context 'concerns' do
    it_behaves_like "identifiable"
    it_behaves_like "containable"
  end

end
