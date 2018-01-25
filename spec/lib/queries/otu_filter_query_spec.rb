require 'rails_helper'
require_relative '../../support/shared_contexts/make_simple_world'

describe Queries::OtuFilterQuery, type: :model, group: [:geo, :collection_objects, :otus] do

  context 'with properly built collection of objects' do
    before {
      simple_world
    }
    # need some people
    let(:sargon) { Person.where(first_name: 'of Akkad', last_name: 'Sargon').first }
    let(:andy) { Person.where(first_name: 'Andy', last_name: 'Worehall', prefix: 'Non-author').first }
    let(:daryl) { Person.where(first_name: 'Daryl', last_name: 'Penfold', prefix: 'with Sargon').first }
    let(:ted) { Person.where(last_name: 'Pomaroy', first_name: 'Ted', prefix: 'HEWIC').first }
    let(:bill) { Person.where(first_name: 'Bill', last_name: 'Ardson').first }

    # need some otus
    let(:top_dog) { Otu.where(name: 'Top Dog').first }
    let(:nuther_dog) { Otu.where(name: 'Another Dog').first }
    let(:spooler) { Otu.where('name like ?', '%spooler%').first }
    let(:p4) { Otu.where(name: 'P4').first }
    let(:by_bill) { Otu.where('name like ?', '%by Bill%').first }
    let(:otu_a) { Otu.where(name: 'Otu_A').first }
    let(:abra) { Otu.where(name: 'Abra').first }
    let(:cadabra) { Otu.where('name like ?', '%cadabra%').first }
    let(:alakazam) { Otu.where('name like ?', '%alakazam%').first }

    # need some areas
    let(:area_a) { GeographicArea.where(name: 'A').first }
    let(:area_b) { GeographicArea.where(name: 'B').first }

    # need some collection objects
    let(:co_a) {
      object = CollectingEvent.where(verbatim_label: 'Eh?').first
      object.collection_objects.first
    }

    context 'area search' do
      context 'named area' do
        let(:params) { {geographic_area_ids: [area_b.id]} }

        specify 'nomen count' do
          result = Queries::OtuFilterQuery.new(params).result
          expect(result.count).to eq(3)
        end

        specify 'specific nomen' do
          result = Queries::OtuFilterQuery.new(params).result
          expect(result).to contain_exactly(p4, spooler, nuther_dog)
        end
      end

      context 'area shapes' do
        let(:params) { {drawn_area_shape: area_a.to_simple_json_feature} }

        specify 'nomen count' do
          result = Queries::OtuFilterQuery.new(params).result
          expect(result.count).to eq(6)
        end

        specify 'specific nomen' do
          result = Queries::OtuFilterQuery.new(params).result
          expect(result).to include(top_dog, by_bill, otu_a, abra, cadabra, alakazam)
        end
      end
    end

    context 'nomen search' do
      context 'with descendants' do
        specify 'with rank' do
          params_with = {nomen_id:    top_dog.taxon_name_id,
                         descendants: '1',
                         rank_class:  'NomenclaturalRank::Iczn::SpeciesGroup::Species'}
          result      = Queries::OtuFilterQuery.new(params_with).result
          expect(result).to contain_exactly(spooler, cadabra)
        end

        specify 'with same rank' do
          params_with = {nomen_id:    top_dog.taxon_name_id,
                         descendants: '1',
                         rank_class:  'NomenclaturalRank::Iczn::FamilyGroup::Family'}
          result      = Queries::OtuFilterQuery.new(params_with).result
          expect(result).to contain_exactly(top_dog, by_bill)
        end

        specify 'without rank' do
          params_with = {nomen_id:    top_dog.taxon_name_id,
                         descendants: '1',
                         rank_class: nil}
          result      = Queries::OtuFilterQuery.new(params_with).result
          expect(result).to contain_exactly(spooler, top_dog, abra, by_bill, cadabra, alakazam)
        end
      end

      specify 'without descendants' do
        params_without = {nomen_id:    top_dog.taxon_name_id,
                          # descendants: nil,
                          rank_class:  'NomenclaturalRank::Iczn::SpeciesGroup::Species'}
        result         = Queries::OtuFilterQuery.new(params_without).result
        expect(result).to contain_exactly(top_dog, by_bill)
      end
    end

    context 'author search' do

      specify 'constructs' do
        expect(Role.where(type: 'TaxonNameAuthor').count).to eq(9)
        expect(Person.with_role('TaxonNameAuthor').count).to eq(4) # Bill, Ted, Daryl, and Sargon
        expect(Protonym.named('Topdogidae').count).to eq(1)
      end

      context 'and' do
        specify 'otus by bill, ted, and daryl' do
          params = {author_ids: [bill.id, ted.id, daryl.id], and_or_select: '_and_'}

          result = Queries::OtuFilterQuery.new(params).result
          expect(result.count).to eq(0)
        end

        specify 'otus by daryl and sargon' do
          params = {author_ids: [sargon.id, daryl.id], and_or_select: '_and_'}

          result = Queries::OtuFilterQuery.new(params).result
          expect(result.count).to eq(1)
        end

        specify 'otus by sargon (single author)' do
          params = {author_ids: [sargon.id], and_or_select: '_and_'}

          result = Queries::OtuFilterQuery.new(params).result
          expect(result.count).to eq(2)
        end

        specify 'otus two out of three authors)' do
          params = {author_ids: [sargon.id, ted.id], and_or_select: '_and_'}

          result = Queries::OtuFilterQuery.new(params).result
          expect(result.count).to eq(1)
        end
      end

      context 'or' do
        specify 'otus by authors' do
          params = {author_ids: [bill.id, sargon.id, daryl.id], and_or_select: '_or_'}

          result = Queries::OtuFilterQuery.new(params).result
          expect(result).to contain_exactly(spooler, cadabra, nuther_dog)
        end
      end
    end

    context 'combined test' do
      specify 'author, author string, geaographic area, taxon name' do

        tn     = co_a.taxon_names.select { |t| t if t.name == 'cadabra' }.first
        params = {}
        params.merge!({author_ids: [bill.id, daryl.id], and_or_select: '_or_'})
        params.merge!({verbatim_author_string: 'Bill A'})
        params.merge!({geographic_area_ids: [area_a.id]})
        params.merge!({nomen_id:    top_dog.taxon_name_id,
                       descendants: '1',
                       rank_class:  'NomenclaturalRank::Iczn::SpeciesGroup::Species'})

        result = Queries::OtuFilterQuery.new(params).result
        expect(result).to contain_exactly(tn.otus.first)
      end
    end
  end
end
