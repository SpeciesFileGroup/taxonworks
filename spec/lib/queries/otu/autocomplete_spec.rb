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

  context 'restrict_to taxon names' do
    specify 'takes unrestricted TaxonName results, filtered by the Otu restriction' do
      expect(Queries::TaxonName::Autocomplete).to receive(:new)
        .with('Erasmoneura', hash_excluding(:restrict_to))
        .and_call_original

      q = Queries::Otu::Autocomplete.new('Erasmoneura', restrict_to: Otu.where(id: otu2.id))
      expect(q.autocomplete).to contain_exactly(otu2)
    end

    specify 'extended takes unrestricted TaxonName results, filtered by the Otu restriction' do
      expect(Queries::TaxonName::Autocomplete).to receive(:new)
        .with('Erasmoneura', hash_excluding(:restrict_to))
        .and_call_original

      q = Queries::Otu::Autocomplete.new('Erasmoneura', restrict_to: Otu.where(id: otu2.id))
      expect(q.autocomplete_taxon_name_extended).to contain_exactly(otu2)
    end

    specify 'keeps a Combination whose valid name is that of a restricted Otu' do
      combination = FactoryBot.create(:valid_combination)
      combination.reload
      o = Otu.create!(taxon_name_id: combination.cached_valid_taxon_name_id)

      q = Queries::Otu::Autocomplete.new(combination.cached, restrict_to: Otu.where(id: o.id))
      expect(q.taxon_name_autocomplete).to include(combination)
      expect(q.autocomplete_taxon_name).to include(o)
    end

    context 'deep TaxonName results' do
      let(:crowd_genus) { Protonym.create!(name: 'Zzyzxdeep', rank_class: Ranks.lookup(:iczn, 'genus'), parent: root) }
      let!(:target_otu) {
        # Shorter names sort first in TaxonName autocomplete
        ('aa'..'az').each do |n|
          Protonym.create!(name: n, rank_class: Ranks.lookup(:iczn, 'species'), parent: crowd_genus)
        end
        Otu.create!(taxon_name: Protonym.create!(name: 'zzzzzzzz', rank_class: Ranks.lookup(:iczn, 'species'), parent: crowd_genus))
      }

      let(:depths) { [] }

      before do
        allow_any_instance_of(Queries::TaxonName::Autocomplete).to receive(:autocomplete).and_wrap_original do |m|
          depths << m.receiver.limit
          m.call
        end
      end

      specify 'are fetched once, DELEGATED_DEPTH deep' do
        q = Queries::Otu::Autocomplete.new('Zzyzxdeep', restrict_to: Otu.where(id: target_otu.id))
        expect(q.autocomplete).to contain_exactly(target_otu)
        expect(depths).to eq([Queries::Query::Autocomplete::DELEGATED_DEPTH])
      end

      specify 'beyond DELEGATED_DEPTH are not found (best effort)' do
        stub_const('Queries::Query::Autocomplete::DELEGATED_DEPTH', 20)

        q = Queries::Otu::Autocomplete.new('Zzyzxdeep', restrict_to: Otu.where(id: target_otu.id))
        expect(q.taxon_name_autocomplete).to eq([])
        expect(depths).to eq([20])
      end
    end

    specify 'finds a restricted Otu whose taxon name is crowded out of the default TaxonName limit' do
      crowd_genus = Protonym.create!(name: 'Zzyzxcrowd', rank_class: Ranks.lookup(:iczn, 'genus'), parent: root)
      # Shorter names sort first in TaxonName autocomplete
      ('aa'..'az').each do |n|
        Protonym.create!(name: n, rank_class: Ranks.lookup(:iczn, 'species'), parent: crowd_genus)
      end
      target = Protonym.create!(name: 'zzzzzzzz', rank_class: Ranks.lookup(:iczn, 'species'), parent: crowd_genus)
      target_otu = Otu.create!(taxon_name: target)

      expect(Queries::TaxonName::Autocomplete.new('Zzyzxcrowd').autocomplete).to_not include(target)

      q = Queries::Otu::Autocomplete.new('Zzyzxcrowd', restrict_to: Otu.where(id: target_otu.id))
      expect(q.autocomplete).to contain_exactly(target_otu)
    end
  end

  context 'limit' do
    let(:crowd_genus) { Protonym.create!(name: 'Zzyzxlimit', rank_class: Ranks.lookup(:iczn, 'genus'), parent: root) }
    let!(:crowd_otus) {
      ('aa'..'az').map do |n|
        Otu.create!(taxon_name: Protonym.create!(name: n, rank_class: Ranks.lookup(:iczn, 'species'), parent: crowd_genus))
      end
    }

    specify 'defaults to nil' do
      expect(Queries::Otu::Autocomplete.new('Zzyzxlimit').limit).to be_nil
    end

    specify 'is passed to the TaxonName autocomplete' do
      expect(Queries::TaxonName::Autocomplete).to receive(:new)
        .with('Zzyzxlimit', hash_including(limit: 30))
        .and_call_original

      Queries::Otu::Autocomplete.new('Zzyzxlimit', limit: 30).autocomplete_taxon_name
    end

    specify 'restricted, finds as many names as the limit asks for' do
      q = Queries::Otu::Autocomplete.new('Zzyzxlimit', limit: 30, restrict_to: Otu.where(id: crowd_otus.map(&:id)))
      expect(q.autocomplete_taxon_name.map(&:id)).to include(*crowd_otus.map(&:id))
    end

    specify 'restricted, keeps no more names than the limit' do
      q = Queries::Otu::Autocomplete.new('Zzyzxlimit', limit: 5, restrict_to: Otu.where(id: crowd_otus.map(&:id)))
      expect(q.taxon_name_autocomplete.size).to eq(5)
    end
  end

end
