require 'rails_helper'

describe Repository, type: :model do
  let(:repository) {FactoryBot.build(:repository)}

  context 'validation' do
    before(:each) {repository.valid?}
    specify 'non collector/updater required attributes' do
      expect(repository.errors.keys.sort).to eq([:acronym, :name ].sort)
    end
  end

  context 'associations' do
    context 'has_many' do
      specify 'collection_objects' do
        expect(repository).to respond_to(:collection_objects)
      end
    end
  end

  context 'scopes' do
    let(:r1) { FactoryBot.create(:valid_repository) }
    let(:r2) { FactoryBot.create(:valid_repository) }
    let!(:s1) { Specimen.create!(total: 1, repository: r1) }
    let!(:s2) { Specimen.create!(total: 1, repository: r2) }

    specify '#used_recently' do
      expect(Repository.used_recently(s1.created_by_id, s1.project_id)).to contain_exactly(r1.id, r2.id)
    end

    specify '#used_in_project' do
      expect(Repository.used_in_project(s1.project_id)).to contain_exactly(r1, r2)
    end
  end

  context 'concerns' do
    it_behaves_like 'notable'
    it_behaves_like 'is_data'
  end

end
