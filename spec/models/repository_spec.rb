require 'spec_helper'


describe Repository do
  let(:repository) {Repository.new}

  context 'validation' do
    before(:each) {repository.valid?}
    specify 'required attributes' do
      expect(repository.errors.keys.sort).to eq([:acronym, :name,  :status, :url])
    end
  end

  context 'associations' do
    context 'has_many' do
      specify 'collection_objects' do
        expect(repository).to respond_to(:collection_objects)
      end
    end
  end

end
