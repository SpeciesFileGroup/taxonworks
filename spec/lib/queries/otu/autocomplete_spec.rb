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
  end

  context 'duplicate filtering' do
    # Helper method to extract the visual label from autocomplete results
    def extract_label(result)
      target = result[:label_target]
      if target.kind_of?(::Otu)
        target.taxon_name ? (target.taxon_name.cached || target.taxon_name.name) : (target.name || '')
      else # TaxonName
        target.cached || target.name
      end
    end

    context 'with synonym relationships' do
      let!(:synonym_taxon) { Protonym.create!(
        name: 'ashtonii',
        rank_class: Ranks.lookup(:iczn, 'species'),
        parent: genus,
        verbatim_author: 'Author',
        year_of_publication: 1900) }
      
      let!(:valid_taxon) { Protonym.create!(
        name: 'ashtonii', 
        rank_class: Ranks.lookup(:iczn, 'species'),
        parent: genus,
        verbatim_author: 'Smith',
        year_of_publication: 1910) }
        
      let!(:otu_with_valid) { Otu.create!(taxon_name: valid_taxon) }
      
      before do
        # Make synonym_taxon a synonym of valid_taxon
        TaxonNameRelationship::Iczn::Invalidating::Synonym.create!(
          subject_taxon_name: synonym_taxon,
          object_taxon_name: valid_taxon
        )
      end

      specify 'does not return visual duplicates in api_autocomplete_extended' do
        q = Queries::Otu::Autocomplete.new('ashtonii', project_id: project_id)
        results = q.api_autocomplete_extended
        
        # Build array of [otu_id, visual_label] pairs
        otu_label_pairs = results.map { |r| [r[:otu].id, extract_label(r)] }
        
        # Verify no duplicates exist
        expect(otu_label_pairs.uniq).to eq(otu_label_pairs)
      end
    end

    context 'when common name and scientific name share substring' do
      # This tests the original bug: searching for "ashton" would return duplicate
      # entries when both the scientific name (ashtoni) and common name (ashton cuckoo
      # bumble bee) contained the search term
      
      let!(:ashton_taxon) { Protonym.create!(
        name: 'ashtoni',
        rank_class: Ranks.lookup(:iczn, 'species'),
        parent: genus,
        verbatim_author: 'Cresson',
        year_of_publication: 1864) }
      
      let!(:ashton_otu) { Otu.create!(taxon_name: ashton_taxon) }
      
      let!(:ashton_common_name) { CommonName.create!(
        name: 'ashton cuckoo bumble bee',
        otu: ashton_otu,
        geographic_area: GeographicArea.first
      ) }

      specify 'returns only one result when searching for substring in both names' do
        # Search for "ashton" which appears in both scientific and common name
        q = Queries::Otu::Autocomplete.new('ashton', project_id: project_id, include_common_names: true)
        results = q.api_autocomplete_extended
        
        ashton_results = results.select { |r| r[:otu].id == ashton_otu.id }
        
        expect(ashton_results.count).to eq(1), 
          "Expected 1 result for OTU but got #{ashton_results.count}"
      end

      specify 'maintains searchability by both scientific and common names' do
        # Verify we can still find the OTU by searching either name type
        
        # Search by scientific name
        sci_results = Queries::Otu::Autocomplete.new('ashtoni', 
          project_id: project_id, 
          include_common_names: true
        ).api_autocomplete_extended
        
        expect(sci_results.any? { |r| r[:otu].id == ashton_otu.id }).to be true
        
        # Search by common name
        common_results = Queries::Otu::Autocomplete.new('cuckoo', 
          project_id: project_id, 
          include_common_names: true
        ).api_autocomplete_extended
        
        expect(common_results.any? { |r| r[:otu].id == ashton_otu.id }).to be true
      end
    end
  end

end
