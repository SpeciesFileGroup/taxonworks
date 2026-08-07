require 'rails_helper'

describe Queries::Otu::Autocomplete, type: :model do
  let(:name) { 'Test' }
  let!(:otu) { Otu.create!(name: name) }

  let(:other_project) { FactoryBot.create(:valid_project, name: 'other') }
  let(:root) { FactoryBot.create(:root_taxon_name)}
  let(:genus) { Protonym.create(name: 'Erasmoneura', rank_class: Ranks.lookup(:iczn, 'genus'), parent: root) }
  let(:original_genus) { Protonym.create(name: 'Bus', rank_class: Ranks.lookup(:iczn, 'genus'), parent: root)   }
  let!(:species) { Protonym.create!(
    name: 'vulnerata',
    rank_class: Ranks.lookup(:iczn, 'species'),
    parent: genus,
    original_genus: original_genus,
    verbatim_author: 'Fitch & Say',
    year_of_publication: 1800) }
  let!(:otu1) {Otu.create(taxon_name: genus)}
  let!(:otu2) {Otu.create(taxon_name: species)}

  let(:species_name) { 'Erasmoneura vulnerata' }
  let(:original_combination) { 'Bus vulnerata' }

  let(:query) { Queries::Otu::Autocomplete.new('Test') }

  specify 'named' do
    expect(query.autocomplete).to contain_exactly(otu)
  end

  specify '#project_id' do
    o = Otu.create!(project: other_project, name: name)
    q = Queries::Otu::Autocomplete.new(name, project_id: project_id)
    expect(q.autocomplete).to contain_exactly(otu)
  end

  specify 'odd otus' do
    o = FactoryBot.create(:valid_otu, name: 'smorf')
    q = Queries::Otu::Autocomplete.new('morf', project_id: project_id)
    expect(q.autocomplete).to contain_exactly(o)
  end

  # having_taxon_name is always true here
  context '#api_autocomplete' do

    context 'api_autocomplete_extended' do

      specify '#api_autocomplete_extended combination without otu' do
        g1 = FactoryBot.create(:iczn_genus, name: 'Aus')
        g2 = FactoryBot.create(:iczn_genus, name: 'Bus', parent_id: g1.parent_id)
        g3 = FactoryBot.create(:iczn_genus, name: 'Cus', parent_id: g1.parent_id)
        s = FactoryBot.create(:iczn_species, name: 'dus', parent_id: g1.parent_id)
        o = Otu.create!(taxon_name: s)
        c = Combination.create!(genus: g2, species: s)

        s.original_genus = g3
        s.original_species = s
        s.save!

        o2 = Otu.create!(name: 'Bus dus')

        q = Queries::Otu::Autocomplete.new('Bus dus', project_id: project_id)

        r = q.api_autocomplete_extended

        # First match is exact OTU name
        expect(r.first[:otu].id).to eq(o2.id)
        expect(r.first[:otu_valid_id]).to eq(o2.id)
        expect(r.first[:label_target].id).to eq(o2.id)
        expect(r.first[:label_target].class.name).to eq('Otu')

        # Second to Combination
        expect(r.last[:otu].id).to eq(o.id)
        expect(r.last[:otu_valid_id]).to eq(o.id)
        expect(r.last[:label_target].id).to eq(c.id)
        expect(r.last[:label_target].class.name).to eq('Combination')
      end

      specify "combination doesn't displace its valid name" do
        c = Combination.create!(genus: genus, species:)

        q = Queries::Otu::Autocomplete.new(
          'Erasmoneura vulnerata',
          having_taxon_name_only: true,
          project_id: project_id
        )

        r = q.api_autocomplete_extended

        expect(r.count).to eq(2)
        expect([r.first[:label_target].id, r.second[:label_target].id])
          .to contain_exactly(c.id, species.id)
      end
    end

    context 'DEPRECATED(?)' do
      specify 'combination without otu' do
        g1 = FactoryBot.create(:iczn_genus, name: 'Aus')
        g2 = FactoryBot.create(:iczn_genus, name: 'Bus', parent_id: g1.parent_id)
        g3 = FactoryBot.create(:iczn_genus, name: 'Cus', parent_id: g1.parent_id)
        s = FactoryBot.create(:iczn_species, name: 'dus', parent_id: g1.parent_id)
        o = Otu.create!(taxon_name: s)
        c = Combination.create!(genus: g2, species: s)

        s.original_genus = g3
        s.original_species = s
        s.save!

        q = Queries::Otu::Autocomplete.new('Bus dus', project_id: project_id)
        expect(q.api_autocomplete).to contain_exactly(o)
      end

      specify 'valid taxon name 1' do
        o = FactoryBot.create(:valid_otu, name: nil, taxon_name: FactoryBot.create(:iczn_species, name: 'smorf'))
        q = Queries::Otu::Autocomplete.new('orf', project_id: project_id)
        expect(q.api_autocomplete == [o]).to be_truthy
      end

      specify 'invalid taxon name 1' do
        a = FactoryBot.create(:iczn_species, name: 'smorf')
        b = FactoryBot.create(:iczn_species, name: 'rho')

        c = TaxonNameRelationship::Iczn::Invalidating::Synonym.create!(subject_taxon_name: a, object_taxon_name: b)

        o = FactoryBot.create(:valid_otu, name: nil, taxon_name: a )
        q = Queries::Otu::Autocomplete.new('smorf', project_id: project_id)
        expect(q.api_autocomplete).to contain_exactly(o)
      end

      specify 'invalid taxon name 2' do
        a = FactoryBot.create(:iczn_species, name: 'smorf')
        b = FactoryBot.create(:iczn_species, name: 'rho')

        c = TaxonNameRelationship::Iczn::Invalidating::Synonym.create!(subject_taxon_name: a, object_taxon_name: b)

        o1 = FactoryBot.create(:valid_otu, name: nil, taxon_name: a )
        o2 = FactoryBot.create(:valid_otu, name: 'smorf' ) # no taxon name

        q = Queries::Otu::Autocomplete.new('smorf', project_id: project_id)
        expect(q.api_autocomplete).to contain_exactly(o1)
      end

      specify 'combination without otu' do
        g1 = FactoryBot.create(:iczn_genus, name: 'Aus')
        g2 = FactoryBot.create(:iczn_genus, name: 'Bus', parent_id: g1.parent_id)
        g3 = FactoryBot.create(:iczn_genus, name: 'Cus', parent_id: g1.parent_id)
        s = FactoryBot.create(:iczn_species, name: 'dus', parent_id: g1.parent_id)
        o = Otu.create!(taxon_name: s)
        c = Combination.create!(genus: g2, species: s)

        s.original_genus = g3
        s.original_species = s
        s.save!

        q = Queries::Otu::Autocomplete.new('Bus dus', project_id: project_id)
        expect(q.api_autocomplete).to contain_exactly(o)
      end
    end

    specify '#open paren' do
      query.terms = 'Scaphoideus ('
      expect(query.autocomplete).to be_truthy
    end

    specify '#genus_species cf' do
      query.terms = 'Scaphoideus cf carinatus'
      expect(query.autocomplete).to be_truthy
    end

    specify '#autocomplete_top_name 2' do
      query.terms = 'Erasmoneura'
      expect(query.autocomplete.first).to eq(otu1)
    end

    specify '#autocomplete_top_cached' do
      query.terms = species_name
      expect(query.autocomplete.first).to eq(otu2)
    end

    specify '#autocomplete_cached_end_wildcard 3' do
      query.terms = 'Erasmon'
      expect(query.autocomplete.to_a).to contain_exactly(otu1, otu2)
    end

    specify '#autocomplete_wildcard_joined_strings 1' do
      query.terms = 'vuln'
      expect(query.autocomplete).to include(otu2)
    end

    specify '#autocomplete_wildcard_joined_strings 2' do
      query.terms = 'rasmon'
      expect(query.autocomplete.first).to eq(otu1)
    end

    specify '#autocomplete_wildcard_joined_strings 3' do
      query.terms = 'ulner'
      expect(query.autocomplete.first).to eq(otu2)
    end

    specify '#autocomplete_wildcard_joined_strings 4' do
      query.terms = 'neur nerat'
      expect(query.autocomplete).to include(otu2)
    end

    specify '#autocomplete_wildcard_joined_strings 5' do
      query.terms = 'E vul'
      expect(query.autocomplete.first).to eq(otu2)
    end

    specify '#autocomplete_wildcard_joined_strings 6' do
      query.terms = 'E. vul'
      expect(query.autocomplete.first).to eq(otu2)
    end

    specify '#autocomplete_wildcard_author_year_joined_pieces 1' do
      query.terms = 'Fitch'
      expect(query.autocomplete.first).to eq(otu2)
    end

    specify '#autocomplete_wildcard_author_year_joined_pieces 2' do
      query.terms = 'Say'
      expect(query.autocomplete.first).to eq(otu2)
    end

    specify '#autocomplete_wildcard_author_year_joined_pieces 3' do
      query.terms = '1800'
      expect(query.autocomplete.first).to eq(otu2)
    end

    specify '#autocomplete_wildcard_author_year_joined_pieces 4' do
      query.terms = 'Fitch 1800'
      expect(query.autocomplete.first).to eq(otu2)
    end

    # Regression: `terms` (Queries::Query#terms) always returns a 2-element
    # array of wildcarded copies of the *whole* query_string, never the
    # query_string split on whitespace. `autocomplete_taxon_name_hybrid` was
    # (mis)written assuming `terms.first`/`terms.second` were the genus and
    # otu.name (e.g. "Tapinoma CASC_2231") words, so `terms.length == 2` was
    # vacuously true for any query, and it trigram-matched the *entire*
    # phrase against both `taxon_names.cached` and `otus.name` instead of
    # matching each word against its own column.
    context '#autocomplete_taxon_name_hybrid' do
      let!(:tapinoma) { Protonym.create!(name: 'Tapinoma', rank_class: Ranks.lookup(:iczn, 'genus'), parent: root) }
      let!(:target) { Otu.create!(taxon_name: tapinoma, name: 'CASC_2231', project_id: project_id) }

      specify 'matches genus term to taxon_names.cached and otu term to otus.name, independently' do
        # This otu.name redundantly restates the genus (as happens in real
        # data, e.g. "Scaphoideus menoni_E26" under genus "Scaphoideus").
        # Under the old whole-phrase bug this shared genus text was enough
        # to pass both trigram conditions even though the otu-specific part
        # ("sp2_Z9") has nothing to do with the query's otu term
        # ("CASC_2231").
        decoy = Otu.create!(taxon_name: tapinoma, name: 'Tapinoma sp2_Z9', project_id: project_id)

        q = Queries::Otu::Autocomplete.new('Tapinoma CASC_2231', project_id: project_id)
        r = q.autocomplete_taxon_name_hybrid.to_a

        expect(r).to include(target)
        expect(r).not_to include(decoy)
      end

      specify 'does not run for single-word queries' do
        q = Queries::Otu::Autocomplete.new('Tapinoma', project_id: project_id)
        expect(q.autocomplete_taxon_name_hybrid).to be_nil
      end

      specify 'does not run for queries with more than two words' do
        q = Queries::Otu::Autocomplete.new('Tapinoma CASC 2231', project_id: project_id)
        expect(q.autocomplete_taxon_name_hybrid).to be_nil
      end
    end

  end

end
