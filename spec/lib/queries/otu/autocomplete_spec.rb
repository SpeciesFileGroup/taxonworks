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

    context '#autocomplete_taxon_name_and_otu_name' do
      let!(:tapinoma) { Protonym.create!(name: 'Tapinoma', rank_class: Ranks.lookup(:iczn, 'genus'), parent: root) }
      let!(:target) { Otu.create!(taxon_name: tapinoma, name: 'CASC_2231', project_id: project_id) }

      specify 'matches an exact single-word taxon name and otu name' do
        q = Queries::Otu::Autocomplete.new('Tapinoma CASC_2231', project_id: project_id)
        expect(q.autocomplete_taxon_name_and_otu_name.to_a).to include(target)
      end

      specify 'matches on prefixes of both terms' do
        q = Queries::Otu::Autocomplete.new('Tapino CASC', project_id: project_id)
        expect(q.autocomplete_taxon_name_and_otu_name.to_a).to include(target)
      end
    end

  end

  context 'restrict_to' do
    let!(:otu2) { Otu.create!(name: name + ' two') }

    specify 'restricts results to the given Otus' do
      q = Queries::Otu::Autocomplete.new(name, restrict_to: Otu.where(id: otu2.id))
      expect(q.autocomplete.map(&:id)).to contain_exactly(otu2.id)
    end

    specify 'is not applied when nil' do
      q = Queries::Otu::Autocomplete.new(name)
      expect(q.autocomplete.map(&:id)).to include(otu.id, otu2.id)
    end
  end

  # Regression: `exact:` was accepted but never actually consulted — #autocomplete
  # ran the full fuzzy QUERIES stack regardless, so a caller asking for an exact
  # match (e.g. Autoselect::Otu::Levels::ColValidName, checking whether an Otu
  # already exists before offering to create one) got back unrelated
  # trigram-similar names instead of [] when no real match existed.
  context 'exact: true' do
    specify 'matches an Otu whose linked TaxonName.cached equals the term exactly' do
      genus = Protonym.create!(name: 'Exactonoma', rank_class: Ranks.lookup(:iczn, 'genus'), parent: root)
      exact_otu = Otu.create!(taxon_name: genus, project_id: project_id)

      q = Queries::Otu::Autocomplete.new(genus.cached, project_id: project_id, exact: true)
      expect(q.autocomplete.to_a).to contain_exactly(exact_otu)
    end

    specify 'excludes fuzzy/substring matches that are not exact' do
      genus = Protonym.create!(name: 'Erasmoneura', rank_class: Ranks.lookup(:iczn, 'genus'), parent: root)
      Otu.create!(taxon_name: genus, project_id: project_id)

      # Without exact:, this term does match (see '#autocomplete_cached_end_wildcard 3' above).
      q = Queries::Otu::Autocomplete.new('Erasmon', project_id: project_id, exact: true)
      expect(q.autocomplete.to_a).to be_empty
    end

    specify 'matches the "Genus morphospecies" pattern: genus cached exact + Otu#name exact' do
      genus = Protonym.create!(name: 'Morphonoma', rank_class: Ranks.lookup(:iczn, 'genus'), parent: root)
      target = Otu.create!(taxon_name: genus, name: 'sp1', project_id: project_id)
      Otu.create!(taxon_name: genus, name: 'sp10', project_id: project_id) # not an exact match on the second word

      q = Queries::Otu::Autocomplete.new('Morphonoma sp1', project_id: project_id, exact: true)
      expect(q.autocomplete.to_a).to contain_exactly(target)
    end

    specify 'does not match the morphospecies pattern when the genus does not exist locally' do
      q = Queries::Otu::Autocomplete.new('Nonexistus sp1', project_id: project_id, exact: true)
      expect(q.autocomplete.to_a).to be_empty
    end

    specify 'does not apply the morphospecies pattern to a query with other than two words' do
      genus = Protonym.create!(name: 'Onewordonoma', rank_class: Ranks.lookup(:iczn, 'genus'), parent: root)
      Otu.create!(taxon_name: genus, name: 'sp1 extra', project_id: project_id)

      q = Queries::Otu::Autocomplete.new('Onewordonoma sp1 extra', project_id: project_id, exact: true)
      expect(q.autocomplete.to_a).to be_empty
    end

    specify 'a same-named Subgenus (e.g. the nominotypical subgenus) is not treated as a genus match' do
      genus = Protonym.create!(name: 'Subgenoma', rank_class: Ranks.lookup(:iczn, 'genus'), parent: root)
      subgenus = Protonym.create!(name: 'Subgenoma', rank_class: Ranks.lookup(:iczn, :subgenus), parent: genus)
      Otu.create!(taxon_name: subgenus, name: 'sp1', project_id: project_id) # would match if Subgenus were allowed
      target = Otu.create!(taxon_name: genus, name: 'sp1', project_id: project_id)

      q = Queries::Otu::Autocomplete.new('Subgenoma sp1', project_id: project_id, exact: true)
      expect(q.autocomplete.to_a).to contain_exactly(target)
    end
  end

end
