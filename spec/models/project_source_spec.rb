require 'rails_helper'

describe ProjectSource do

  let(:project_source) { FactoryBot.build(:project_source) }

  specify '#batch_sync_to_project :add' do
    a = FactoryBot.create(:valid_source_bibtex)
    ProjectSource.batch_sync_to_project( {source_query:  {source_id: a.id}}, :add, project_id )
    expect( Project.find(project_id).project_sources.map(&:source_id).include?(a.id) ).to be_truthy
  end

  specify '#batch_sync_to_project :add continues past sources already in the project' do
    a = FactoryBot.create(:valid_source_bibtex)
    b = FactoryBot.create(:valid_source_bibtex)
    FactoryBot.create(:valid_project_source, source: a, project_id:)

    expect(
      ProjectSource.batch_sync_to_project( {source_query: {source_id: [a.id, b.id]}}, :add, project_id )
    ).to eq(1)
    expect( Project.find(project_id).project_sources.map(&:source_id) ).to include(a.id, b.id)
  end

  specify '#batch_sync_to_project :remove' do
    a = FactoryBot.create(:valid_source_bibtex)
    FactoryBot.create(:valid_project_source, source: a, project_id:)

    ProjectSource.batch_sync_to_project( {source_query:  {source_id: a.id}}, :remove, project_id )
    expect( Project.find(project_id).project_sources.map(&:source_id).include?(a.id) ).to be_falsey
  end

  specify '#batch_sync_to_project :remove does not remove a source cited in the project' do
    a = FactoryBot.create(:valid_source_bibtex)
    FactoryBot.create(:valid_citation, source: a) # adds a to the project

    expect(
      ProjectSource.batch_sync_to_project(
        {source_query:  {source_id: a.id}}, :remove, project_id
      )
    ).to eq(0)
    expect(
      Project.find(project_id).project_sources.map(&:source_id).include?(a.id)
    ).to be_truthy
  end

  specify '#batch_sync_to_project :remove removes a source cited only in another project' do
    other_project = FactoryBot.create(:valid_project)
    a = FactoryBot.create(:valid_source_bibtex)
    FactoryBot.create(:valid_project_source, source: a, project_id:)
    # Adds `a` to other_project
    FactoryBot.create(:valid_citation, source: a, project: other_project)

    expect(
      ProjectSource.batch_sync_to_project(
        {source_query:  {source_id: a.id}}, :remove, project_id
      )
    ).to eq(1)
    expect(
      Project.find(project_id).project_sources.map(&:source_id).include?(a.id)
    ).to be_falsey
    expect(
      other_project.project_sources.map(&:source_id).include?(a.id)
    ).to be_truthy
  end

  specify '#batch_sync_to_project :remove only removes from the given project' do
    other_project = FactoryBot.create(:valid_project)
    a = FactoryBot.create(:valid_source_bibtex)
    FactoryBot.create(:valid_project_source, source: a, project_id:)
    FactoryBot.create(:valid_project_source, source: a, project: other_project)

    ProjectSource.batch_sync_to_project( {source_query:  {source_id: a.id}}, :remove, project_id )
    expect( other_project.project_sources.map(&:source_id).include?(a.id) ).to be_truthy
  end

  specify '#batch_sync_to_project :remove only removes the filtered sources' do
    a = FactoryBot.create(:valid_source_bibtex)
    b = FactoryBot.create(:valid_source_bibtex)
    FactoryBot.create(:valid_project_source, source: a, project_id:)
    FactoryBot.create(:valid_project_source, source: b, project_id:)

    ProjectSource.batch_sync_to_project( {source_query:  {source_id: a.id}}, :remove, project_id )
    expect( Project.find(project_id).project_sources.map(&:source_id) ).to include(b.id)
  end

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
