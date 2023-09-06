require 'rails_helper'

describe Queries::Otu::Autocomplete, type: :model do
  let(:name) { 'Test' }
  let!(:otu) { Otu.create!(name:) }

  let(:other_project) { FactoryBot.create(:valid_project, name: 'other') }

  let(:query) { Queries::Otu::Autocomplete.new('Test') }

  specify 'named' do
    expect(query.autocomplete).to contain_exactly(otu)
  end

  specify '#project_id' do
    o = Otu.create!(project: other_project, name:)
    q = Queries::Otu::Autocomplete.new('Test', project_id:)
    expect(q.autocomplete).to contain_exactly(otu)
  end

  specify 'odd otus' do
    o = FactoryBot.create(:valid_otu, name: 'smorf')
    q = Queries::Otu::Autocomplete.new('smo', project_id:)
    expect(q.autocomplete).to contain_exactly(o)
  end

  # having_taxon_name is always true here
  context '#api_autocomplete' do
    specify 'valid taxon name 1' do
      o = FactoryBot.create(:valid_otu, name: nil, taxon_name: FactoryBot.create(:iczn_species, name: 'smo'))
      q = Queries::Otu::Autocomplete.new('smo', project_id:)

      expect(q.api_autocomplete).to contain_exactly(o)
    end

    specify 'invalid taxon name 1' do
      a = FactoryBot.create(:iczn_species, name: 'smo')
      b = FactoryBot.create(:iczn_species, name: 'rho')

      c = TaxonNameRelationship::Iczn::Invalidating::Synonym.create!(subject_taxon_name: a, object_taxon_name: b)

      o = FactoryBot.create(:valid_otu, name: nil, taxon_name: a )
      q = Queries::Otu::Autocomplete.new('smo', project_id:)
      expect(q.api_autocomplete).to contain_exactly(o)
    end

    specify 'invalid taxon name 2' do
      a = FactoryBot.create(:iczn_species, name: 'smo')
      b = FactoryBot.create(:iczn_species, name: 'rho')

      c = TaxonNameRelationship::Iczn::Invalidating::Synonym.create!(subject_taxon_name: a, object_taxon_name: b)

      o1 = FactoryBot.create(:valid_otu, name: nil, taxon_name: a )
      o2 = FactoryBot.create(:valid_otu, name: 'smo' ) # no taxon name

      q = Queries::Otu::Autocomplete.new('smo', project_id:)
      expect(q.api_autocomplete).to contain_exactly(o1)
    end


  end

end
