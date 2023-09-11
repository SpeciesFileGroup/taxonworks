require 'rails_helper'

describe ProjectSource do

  let(:project_source) { FactoryBot.build(:project_source) }

  context 'validation' do
    before(:each) { project_source.valid? }

    context 'requires' do
      specify 'project' do
        expect(project_source.errors.include?(:project)).to be_falsey
      end

      specify 'source' do
        expect(project_source.save).to be_falsey
      end
    end
  end

  context 'validation' do
    specify 'source is unique per project' do
      s = FactoryBot.create(:valid_source)
      a = ProjectSource.new(project_id: 1, source: s)
      b = ProjectSource.new(project_id: 1, source: s)
      expect(a.save).to be_truthy
      expect(b.valid?).to be(false)
      expect(b.errors.include?(:source_id)).to be(true)
    end
  end

  context 'destroying' do
    let!(:ps1) { FactoryBot.create(:valid_project_source) }
    let!(:c) { FactoryBot.create(:valid_citation, source: ps1.source, project: ps1.project) }

    specify 'is prevented when used' do
      ps1.destroy
      expect(ps1.destroyed?).to be_falsey
    end

  end

  context 'concerns' do
    it_behaves_like 'is_data'
  end

end
