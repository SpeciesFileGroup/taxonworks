require 'rails_helper'

require_relative "shared_context"

describe Queries::Source::Filter, type: :model, group: [:sources] do

  # lib/queries/source/shared_context.rb
  include_examples 'source queries'

  let(:query) {  Queries::Source::Filter.new({})  }

  specify '#with_doi 1' do
    Identifier::Global::Doi.create!(identifier_object: s1, identifier: 'http://dx.doi.org/10.11646/stuff.1234.5.6')
    query.with_doi = true
    expect(query.all.map(&:id)).to contain_exactly(s1.id)
  end

  specify '#with_doi 2' do
    Identifier::Global::Doi.create!(identifier_object: s2, identifier: 'http://dx.doi.org/10.11646/stuff.1234.5.6')
    query.with_doi = false
    expect(query.all.map(&:id)).to contain_exactly( *all_source_ids - [s2.id] )
  end

  specify '#nomenclature 1' do
    Citation.create!(source: s1, citation_object: FactoryBot.create(:root_taxon_name))
    query.nomenclature = true
    expect(query.all.map(&:id)).to contain_exactly(s1.id)
  end

  specify '#nomenclature 2' do
    a = Citation.create!(source: s1, citation_object: FactoryBot.create(:valid_specimen)) # dummy citation
    query.nomenclature = false
    expect(query.all.map(&:id)).to contain_exactly( *all_source_ids )
  end

  specify '#documents 1' do
    FactoryBot.create(:valid_documentation, documentation_object: s1)
    query.documents = true
    expect(query.all.map(&:id)).to contain_exactly(s1.id)
  end

  specify '#documents 2' do
    query.documents = false
    expect(query.all.map(&:id)).to contain_exactly( *all_source_ids )
  end

  specify '#roles 1' do
    query.roles = true
    expect(query.all.map(&:id)).to contain_exactly(s2.id, s4.id)
  end

  specify '#roles 2' do
    query.roles = false
    expect(query.all.map(&:id)).to contain_exactly( *(all_source_ids - [s2.id, s4.id]) )
  end

  specify '#citations 1' do
    Citation.create!(source: s1, citation_object: FactoryBot.create(:valid_otu))
    query.citations = true
    expect(query.all.map(&:id)).to contain_exactly(s1.id)
  end

  specify '#citations 2' do
    Citation.create!(source: s1, citation_object: FactoryBot.create(:valid_otu))
    query.citations = false
    expect(query.all.map(&:id)).to contain_exactly( *(all_source_ids - [s1.id]) )
  end

  specify '#title, #exact_title' do
    query.title = 'Creatures from the Black Lagoon.'
    expect(query.all.map(&:id)).to contain_exactly(s5.id)
  end

  specify '#title' do
    query.title = 'Creatures'
    expect(query.all.map(&:id)).to contain_exactly(s5.id)
  end

  specify '#year_start' do
    query.year_start = 1940
    expect(query.all.map(&:id)).to contain_exactly(s5.id)
  end

  specify '#year_end' do
    query.year_start = 1921
    query.year_end = 1940
    expect(query.all.map(&:id)).to contain_exactly(s3.id, s4.id, s5.id)
  end

  specify '#author_ids' do
    query.author_ids = [p1.id]
    expect(query.all.map(&:id)).to contain_exactly(s2.id, s4.id)
  end

  specify '#exact_author' do
    query.author = 'Smith'
    query.exact_author = true
    expect(query.all.map(&:id)).to contain_exactly(s2.id, s3.id)
  end

  specify '#author' do
    query.author = 'Smith'
    expect(query.all.map(&:id)).to contain_exactly(s2.id, s3.id, s4.id)
  end

  specify '#project_id / in_project 1' do
    query.project_id = 1
    query.in_project = true 
    expect(query.all.map(&:id)).to contain_exactly()
  end

  specify '#project_id / in_project 2' do
    query.project_id = 1
    query.in_project = false
    expect(query.all.map(&:id)).to contain_exactly(*all_source_ids)
  end

  specify '#project_id / in_project 3' do
    ProjectSource.create!(source: s1, project_id: Current.project_id)
    query.project_id = Current.project_id 
    query.in_project = true 
    expect(query.all.map(&:id)).to contain_exactly(s1.id)
  end

  specify '#query_term' do
    q = Queries::Source::Filter.new(query_term: 'Unintelligible')
    expect(q.all.map(&:id)).to contain_exactly(s1.id)
  end

  specify '#query_string' do
    query.query_string = 'Unintelligible'
    expect(query.terms).to contain_exactly('Unintelligible%', '%Unintelligible%')
    expect(query.all.map(&:id)).to contain_exactly(s1.id)
  end

end
