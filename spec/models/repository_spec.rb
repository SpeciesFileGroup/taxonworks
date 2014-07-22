require 'rails_helper'


describe Repository do
  let(:repository) {FactoryGirl.build(:repository)}

  context 'validation' do
    before(:each) {repository.valid?}
    specify 'non collector/updater required attributes' do
      expect(repository.errors.keys.sort).to eq([:acronym, :name,  :status, :url].sort)
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
