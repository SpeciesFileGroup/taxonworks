require 'rails_helper'

describe Queries::Repository::Autocomplete, type: :model do
  let!(:heavily_used) { FactoryBot.create(:valid_repository, name: 'Heavily Used Repo', acronym: 'ZBBB') }
  let!(:unused) { FactoryBot.create(:valid_repository, name: 'Unused Repo', acronym: 'ZBBC') }

  let(:query) { Queries::Repository::Autocomplete.new('ZBB', project_id: [project_id]) }

  specify 'a matching repository used across many other projects does not crowd out a matching, unused repository' do
    10.times do
      p = FactoryBot.create(:valid_project)
      Specimen.create!(total: 1, repository: heavily_used, project_id: p.id)
    end

    expect(query.autocomplete.map(&:id)).to include(unused.id)
  end

  specify 'use_count reflects total usage across all projects, not a single project group' do
    other_project = FactoryBot.create(:valid_project)
    Specimen.create!(total: 1, repository: heavily_used, project_id: project_id)
    Specimen.create!(total: 1, repository: heavily_used, project_id: other_project.id)

    result = query.autocomplete.detect { |r| r.id == heavily_used.id }
    expect(result.use_count).to eq(2)
  end

  specify 'a matching repository is only returned once, regardless of how many projects it is used in' do
    3.times do
      p = FactoryBot.create(:valid_project)
      Specimen.create!(total: 1, repository: heavily_used, project_id: p.id)
    end

    expect(query.autocomplete.map(&:id).count { |id| id == heavily_used.id }).to eq(1)
  end
end
