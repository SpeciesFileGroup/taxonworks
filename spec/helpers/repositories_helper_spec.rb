require 'rails_helper'

describe RepositoriesHelper, type: :helper do
  context 'a repository needs some helpers' do
    let(:repository) {FactoryBot.create(:valid_repository)}
    let(:tag) {"#{repository.name} (#{repository.acronym})"}

    specify '.repository_tag' do
      expect(helper.repository_tag(repository)).to eq(tag)
    end

    specify '.repository_link' do
      expect(helper.repository_link(repository)).to have_link(repository.name)
    end

    specify '.repositories_search_form' do
      expect(helper.repositories_search_form).to have_field('repository_id_for_quick_search_form')
    end

  end

  context '.repository_usage_tag' do
    let(:repository) { FactoryBot.create(:valid_repository) }
    let(:other_repository) { FactoryBot.create(:valid_repository, name: 'Other', acronym: 'OTHR') }
    let(:project) { FactoryBot.create(:valid_project) }

    before do
      allow(helper).to receive(:sessions_current_project_id).and_return(project.id)
    end

    specify 'does not double count a collection object housed at, and currently located at, the same repository' do
      Specimen.create!(total: 1, repository: repository, current_repository: repository, project_id: project.id)

      expect(helper.repository_usage_tag(repository)).to include('Used:&nbsp;1')
    end

    specify 'counts a collection object housed elsewhere but currently at the repository' do
      Specimen.create!(total: 1, repository: other_repository, current_repository: repository, project_id: project.id)

      expect(helper.repository_usage_tag(repository)).to include('Used:&nbsp;1')
    end

    specify 'counts a collection object housed at the repository but currently elsewhere' do
      Specimen.create!(total: 1, repository: repository, current_repository: other_repository, project_id: project.id)

      expect(helper.repository_usage_tag(repository)).to include('Used:&nbsp;1')
    end
  end
end
