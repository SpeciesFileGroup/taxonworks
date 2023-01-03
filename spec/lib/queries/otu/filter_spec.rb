require 'rails_helper'
require 'support/shared_contexts/shared_geo'

describe Queries::Otu::Filter, type: :model, group: [:geo, :collection_objects, :otus, :shared_geo] do

  let(:q) { Queries::Otu::Filter.new({}) }

  let(:o1) { Otu.create!(name: 'Abc 1') }
  let(:o2) { Otu.create!(name: 'Def 2') }

  specify 'biological_association_id' do
    s1 = Specimen.create

    s1.taxon_determinations << TaxonDetermination.new(otu: o1)

    b1 = FactoryBot.create(
      :valid_biological_association,
      biological_association_subject: s1,
      biological_association_object: o2)
    b2 = FactoryBot.create(:valid_biological_association) # 

    q.biological_association_id = [b1.id]
    expect(q.all).to contain_exactly(o1, o2)
  end

  specify 'biological_association_id historical_determinations 1' do
    s1 = Specimen.create

    s1.taxon_determinations << TaxonDetermination.new(otu: o1)
    s1.taxon_determinations << TaxonDetermination.new(otu: o2)

    b1 = FactoryBot.create(
      :valid_biological_association,
      biological_association_subject: s1,
      biological_association_object: o2)
    
    FactoryBot.create(:valid_biological_association)

    q.biological_association_id = [b1.id]
    expect(q.all).to contain_exactly(o2)
  end

  specify 'biological_association_id historical_determinations 2' do
    s1 = Specimen.create

    s1.taxon_determinations << TaxonDetermination.new(otu: o1)
    s1.taxon_determinations << TaxonDetermination.new(otu: o2)

    b1 = FactoryBot.create(
      :valid_biological_association,
      biological_association_subject: s1,
      biological_association_object: o2)

    FactoryBot.create(:valid_biological_association) 

    q.biological_association_id = [b1.id]
    q.historical_determinations = false 

    expect(q.all).to contain_exactly(o1, o2)
  end

  specify 'biological_association_id historical_determinations 3' do
    s1 = Specimen.create
    s2 = Specimen.create

    s1.taxon_determinations << TaxonDetermination.new(otu: o1)
    s1.taxon_determinations << TaxonDetermination.new(otu: o2)

    b1 = FactoryBot.create(
      :valid_biological_association,
      biological_association_subject: s1,
      biological_association_object: s2)

    FactoryBot.create(:valid_biological_association)

    q.biological_association_id = [b1.id]
    q.historical_determinations = true
    expect(q.all).to contain_exactly(o1)
  end

  specify 'collecting_event_id' do
    s1 = Specimen.create(collecting_event: FactoryBot.create(:valid_collecting_event))
    s2 = Specimen.create(collecting_event: FactoryBot.create(:valid_collecting_event))

    s1.taxon_determinations << TaxonDetermination.new(otu: o1)
    s1.taxon_determinations << TaxonDetermination.new(otu: o2) # should be current
    s2.taxon_determinations << TaxonDetermination.new(otu: o1)
   
    q.collecting_event_id = s1.collecting_event_id
    expect(q.all.map(&:id)).to contain_exactly(o2.id)
  end

  specify 'collecting_event_id, historical_determinations 1' do
    s1 = Specimen.create(collecting_event: FactoryBot.create(:valid_collecting_event))
    s2 = Specimen.create(collecting_event: FactoryBot.create(:valid_collecting_event))

    s1.taxon_determinations << TaxonDetermination.new(otu: o1)
    s1.taxon_determinations << TaxonDetermination.new(otu: o2) # should be current
    s2.taxon_determinations << TaxonDetermination.new(otu: o1)
   
    q.collecting_event_id = s1.collecting_event_id
    q.historical_determinations = true
    expect(q.all.map(&:id)).to contain_exactly(o1.id)
  end

  specify 'collecting_event_id, historical_determinations 1' do
    s1 = Specimen.create(collecting_event: FactoryBot.create(:valid_collecting_event))
    s2 = Specimen.create(collecting_event: FactoryBot.create(:valid_collecting_event))

    s1.taxon_determinations << TaxonDetermination.new(otu: o1)
    s1.taxon_determinations << TaxonDetermination.new(otu: o2) # should be current
    s2.taxon_determinations << TaxonDetermination.new(otu: o1)
   
    q.collecting_event_id = s1.collecting_event_id
    q.historical_determinations = false
    expect(q.all.map(&:id)).to contain_exactly(o1.id, o2.id)
  end

  specify 'otu_id' do
    q.otu_id = o1.id
    expect(q.all.map(&:id)).to contain_exactly(o1.id)
  end

  specify 'otu_id []' do
    q.otu_id = [o1.id]
    expect(q.all.map(&:id)).to contain_exactly(o1.id)
  end

  specify 'name' do
    o1; o2
    q.name = 'A' 
    expect(q.all.map(&:id)).to contain_exactly(o1.id)
  end

  specify 'name []' do
    o1; o2
    q.name = ['A']
    expect(q.all.map(&:id)).to contain_exactly(o1.id)
  end
    
  specify 'name, name_exact 1' do
    o1; o2
    q.name = ['A']
    q.name_exact = true
    expect(q.all.map(&:id)).to contain_exactly()
  end

  specify 'name, name_exact 2' do
    o1; o2
    q.name = 'Abc 1'
    q.name_exact = true 
    expect(q.all.map(&:id)).to contain_exactly(o1.id)
  end

  specify 'taxon_name_id' do
    o1.update(taxon_name_id: FactoryBot.create(:root_taxon_name).id)
    q.taxon_name_id = o1.taxon_name_id
    expect(q.all.map(&:id)).to contain_exactly(o1.id)
  end

  specify 'taxon_name_id []' do
    o1.update(taxon_name_id: FactoryBot.create(:root_taxon_name).id)
    q.taxon_name_id = [o1.taxon_name_id]
    expect(q.all.map(&:id)).to contain_exactly(o1.id)
  end

  # Queries::TaxonName::Filter integration

  specify 'Queries::TaxonName::Filter integration' do
    o1.update!(
      taxon_name:  Protonym.create!(name: 'Aus', rank_class:  Ranks.lookup(:iczn, :genus), parent: find_or_create_root_taxon_name)
    )
    q.taxon_name_query.name = 'Aus'
    expect(q.all.map(&:id)).to contain_exactly(o1.id)
  end

  specify 'Queries::CollectionObject::Filter integration' do
    a = FactoryBot.create(:valid_taxon_determination, otu: o1)
    q.collection_object_query.collection_object_id= [a.biological_collection_object_id]
    expect(q.all.map(&:id)).to contain_exactly(o1.id)
  end

  specify 'Queries::CollectingEvent::Filter integration' do
    a = FactoryBot.create(:valid_taxon_determination, otu: o1)
    a.biological_collection_object.update!(collecting_event: FactoryBot.create(:valid_collecting_event))

    q.collecting_event_query.collecting_event_id = [a.biological_collection_object.collecting_event.id]
    expect(q.all.map(&:id)).to contain_exactly(o1.id)
  end

  specify 'Queries::AssertedDistribution::Filter integration' do
    a = FactoryBot.create(:valid_asserted_distribution, otu: o1)
    q.asserted_distribution_query.otu_id = [o1.id]
    expect(q.all.map(&:id)).to contain_exactly(o1.id)
  end

  specify 'Queries::BiologicalAssociation::Filter integration' do
    a = FactoryBot.create(:valid_biological_association, biological_association_subject: o1)
    q.biological_association_query.otu_id = [o1.id]
    expect(q.all.map(&:id)).to contain_exactly(o1.id)
  end

=begin
  context 'no geo world:' do
    let!(:t1) { find_or_create_root_taxon_name }
    let!(:t2) {
      Protonym.create!(
        name: 'Vlorf',
        verbatim_author: 'Smith',
        rank_class: Ranks.lookup(:iczn, :genus),
        parent: t1)
    }
    let!(:t3) {
      Protonym.create!(
        name: 'Glorf',
        verbatim_author: 'Jones',
        rank_class: Ranks.lookup(:iczn, :genus),
        parent: t1)
    }

    let!(:otu1) { Otu.create!(name: 'one') }
    let!(:otu2) { Otu.create!(name: 'two') }
    let!(:otu3) { Otu.create!(taxon_name: t2) }

    let!(:biological_relationship) { FactoryBot.create(:valid_biological_relationship) }

    let!(:ba1) do
      BiologicalAssociation.create!(
        biological_association_subject: otu1,
        biological_relationship: biological_relationship,
        biological_association_object: otu2)
    end

    let!(:ba2) do
      BiologicalAssociation.create!(
        biological_association_subject: otu2,
        biological_relationship: biological_relationship,
        biological_association_object: otu3)
    end

    let!(:tnc1) do
      TaxonNameClassification.create!(
        taxon_name: t2,
        type: 'TaxonNameClassification::Iczn::Available')
    end
    let!(:tnr1) do
      TaxonNameRelationship.create!(
        subject_taxon_name: t2,
        type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym',
        object_taxon_name: t3)
    end

    let!(:ad1) { FactoryBot.create(:valid_asserted_distribution, otu: otu2) }

    let(:query) { Queries::Otu::Filter.new({}) }

    context 'query params' do

      specify '#name' do
        query.name = otu1.name
        expect(query.all).to contain_exactly(otu1)
      end

      specify '#taxon_name_relationship_ids 1' do
        query.taxon_name_relationship_ids = [tnr1.id]
        expect(query.all.map(&:id)).to contain_exactly(otu3.id)
      end

      specify '#taxon_name_classification_ids 1' do
        query.taxon_name_classification_ids = [tnc1.id]
        expect(query.all.map(&:id)).to contain_exactly(otu3.id)
      end

      specify '#asserted_distribution_ids 1' do
        query.asserted_distribution_ids = [ad1.id]
        expect(query.all.map(&:id)).to contain_exactly(otu2.id)
      end

      specify '#asserted_distribution_ids 2' do
        # and queries find nothing, but execute
        query.asserted_distribution_ids = [ad1.id]
        query.taxon_name_id = [t1.id]
        expect(query.all.map(&:id)).to contain_exactly()
      end

      specify '#taxon_name_id 1' do
        expect(query.taxon_name_id).to eq([])
      end

      specify '#taxon_name_id 2' do
        query.taxon_name_id = [t2.id]
        expect(query.ids_for_taxon_name).to contain_exactly(t2.id)
      end

      specify '#otu_id' do
        expect(query.otu_id).to eq([])
      end

      specify '#otu_id 2' do
        query.otu_id = [otu1.id, otu3.id]
        expect(query.ids_for_otu).to contain_exactly(otu1.id, otu3.id)
      end

      specify '#biological_associations_ids 0' do
        query.biological_association_ids = [ba1.id]
        expect(query.merge_clauses.all.map(&:id)).to contain_exactly(otu1.id, otu2.id)
      end

      specify '#biological_associations_ids 1' do
        query.biological_association_ids = [ba1.id]
        expect(query.all.map(&:id)).to contain_exactly(otu1.id, otu2.id)
      end

      specify '#biological_associations_ids 2' do
        query.biological_association_ids = [ba1.id, ba2.id]
        expect(query.all.map(&:id)).to contain_exactly(otu1.id, otu2.id, otu3.id)
      end

      specify '#biological_associations_ids 3' do
        query.biological_association_ids = [ba2.id]
        expect(query.all.map(&:id)).to contain_exactly(otu2.id, otu3.id)
      end

      specify '#taxon_name_id' do
        query.taxon_name_id = t2.id
        expect(query.all.map(&:id)).to contain_exactly(otu3.id)
      end

      specify '#taxon_name_id' do
        query.taxon_name_id = [t2.id]
        expect(query.all.map(&:id)).to contain_exactly(otu3.id)
      end

      specify '#otu_id' do
        query.otu_id = otu1.id
        expect(query.all.map(&:id)).to contain_exactly(otu1.id)
      end

      specify '#otu_id' do
        query.otu_id = [otu1.id, otu2.id]
        expect(query.all.map(&:id)).to contain_exactly(otu1.id, otu2.id)
      end

      specify 'all ids' do
        query.biological_association_ids = [ba2.id]
        query.otu_id = [otu3.id]
        query.taxon_name_ids = [t2.id]
        query.taxon_name_classification_ids = [tnc1.id]

        expect(query.all.map(&:id)).to contain_exactly(otu3.id)
      end

    end
  end

  context 'with properly built collection of objects' do
    include_context 'stuff for complex geo tests'

    before { [co_a, co_b, gr_a, gr_b] }

    specify 'lint setup 1' do
      expect(Role.where(type: 'TaxonNameAuthor').count).to eq(9)
    end

    specify 'lint setup 2' do
      expect(Person.with_role('TaxonNameAuthor').count).to eq(4) # Bill, Ted, Daryl, and Sargon
    end

    specify 'lint setup 3' do
      expect(Protonym.named('Topdogidae').count).to eq(1)
    end

    context 'area search' do
      let(:cite2) { FactoryBot.create(:valid_citation, citation_object: by_bill) }

      let(:ad2) do
        ad = AssertedDistribution.new(
          otu: by_bill,
          geographic_area: sub_area_b,
          by: geo_user,
          project: geo_project)
        ad.origin_citation = cite2
        ad.save!
        ad
      end
      let(:params) do
        {geographic_area_ids: [area_b.id],
         selection_objects: ['CollectionObject', 'AssertedDistribution']}
      end

      context 'named area' do
        specify 'nomen count' do
          ad2 # create the asserted_distribution to find.
          result = Queries::Otu::Filter.new(params).result
          expect(result.count).to eq(4) # three by 'CollectionObject', one by 'AssertedDistribution'
        end

        specify 'specific nomen' do
          ad2 # create the asserted_distribution to find.
          result = Queries::Otu::Filter.new(params).result
          expect(result).to contain_exactly(otu_p4, spooler, nuther_dog, by_bill)
        end
      end

      context 'area shapes' do
        let(:params) { {drawn_area_shape: area_a.to_simple_json_feature,
                        selection_objects: ['CollectionObject', 'AssertedDistribution']} }
        let(:ad2a) do
          ad2.update(geographic_area:  sub_area_a)
        end

        specify 'nomen count' do
          ad2a # create the asserted_distribution to find.
          result = Queries::Otu::Filter.new(params).result
          expect(result.count).to eq(6) # six by 'CollectionObject', one by 'AssertedDistribution', but one (by_bill)
          # is the same otu, and only listed once.
        end

        specify 'specific nomen' do
          ad2a # create the asserted_distribution to find.
          result = Queries::Otu::Filter.new(params).result
          expect(result).to include(top_dog, by_bill, otu_a, abra, cadabra, alakazam)
        end
      end
    end

    context 'nomen search' do
      context 'with descendants' do
        specify 'with rank' do
          params_with = {
            taxon_name_id: top_dog.taxon_name_id,
            descendants: '1',
            rank_class: 'NomenclaturalRank::Iczn::SpeciesGroup::Species'}
          result = Queries::Otu::Filter.new(params_with).result
          expect(result).to contain_exactly(spooler, cadabra)
        end

        specify 'with same rank' do
          params_with = {
            taxon_name_id: top_dog.taxon_name_id,
            descendants: '1',
            rank_class: 'NomenclaturalRank::Iczn::FamilyGroup::Family'}
          result = Queries::Otu::Filter.new(params_with).result
          expect(result).to contain_exactly(top_dog, by_bill)
        end

        specify 'without rank' do
          params_with = {
            taxon_name_id: top_dog.taxon_name_id,
            descendants: '1',
            rank_class: nil}
          result = Queries::Otu::Filter.new(params_with).result
          expect(result).to contain_exactly(spooler, top_dog, abra, by_bill, cadabra, alakazam)
        end
      end

      specify 'without descendants' do
        params_without = {
          taxon_name_id: top_dog.taxon_name_id,
          rank_class: Ranks.lookup(:iczn, :species)}
        result = Queries::Otu::Filter.new(params_without).result
        expect(result).to contain_exactly(top_dog, by_bill)
      end
    end

    context 'author search' do

      context 'and' do
        specify 'otus by bill, ted, and daryl' do
          params = {author_ids: [bill.id, ted.id, daryl.id], and_or_select: '_and_'}

          result = Queries::Otu::Filter.new(params).result
          expect(result.count).to eq(0)
        end

        specify 'otus by daryl and sargon' do
          params = {author_ids: [sargon.id, daryl.id], and_or_select: '_and_'}

          result = Queries::Otu::Filter.new(params).result
          expect(result.count).to eq(1)
        end

        specify 'otus by sargon (single author)' do
          params = {author_ids: [sargon.id], and_or_select: '_and_'}

          result = Queries::Otu::Filter.new(params).result
          expect(result.count).to eq(2)
        end

        specify 'otus two out of three authors)' do
          params = {author_ids: [sargon.id, ted.id], and_or_select: '_and_'}

          result = Queries::Otu::Filter.new(params).result
          expect(result.count).to eq(1)
        end
      end

      context 'or' do
        specify 'otus by authors' do
          params = {author_ids: [bill.id, sargon.id, daryl.id], and_or_select: '_or_'}

          result = Queries::Otu::Filter.new(params).result
          expect(result).to contain_exactly(spooler, cadabra, nuther_dog)
        end
      end
    end

    context 'combined test' do
      specify 'author, author string, geaographic area, taxon name' do
        tn = co_a.taxon_names.select { |t| t if t.name == 'cadabra' }.first
        params = {}
        params.merge!({author_ids: [bill.id, daryl.id], and_or_select: '_or_'})
        params.merge!({verbatim_author: 'Bill A'})
        params.merge!({geographic_area_ids: [area_a.id]})

        params.merge!({
          taxon_name_id: top_dog.taxon_name_id,
          descendants: '1',
          rank_class: 'NomenclaturalRank::Iczn::SpeciesGroup::Species'
        })

        result = Queries::Otu::Filter.new(params).result
        expect(result).to contain_exactly(tn.otus.first)
      end
    end
  end
=end
end
