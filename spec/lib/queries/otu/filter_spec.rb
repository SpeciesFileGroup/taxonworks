require 'rails_helper'
require 'support/shared_contexts/shared_geo'

describe Queries::Otu::Filter, type: :model, group: [:geo, :collection_objects, :otus, :shared_geo] do

  context 'with properly built collection of objects' do
    include_context 'stuff for complex geo tests'

    before {
      co_a
      co_b
      gr_a
      gr_b
    }

    context 'area search' do
      context 'named area' do
        let(:params) { {geographic_area_ids: [area_b.id]} }

        specify 'nomen count' do
          result = Queries::Otu::Filter.new(params).result
          expect(result.count).to eq(3)
        end

        specify 'specific nomen' do
          result = Queries::Otu::Filter.new(params).result
          expect(result).to contain_exactly(otu_p4, spooler, nuther_dog)
        end
      end

      context 'area shapes' do
        let(:params) { {drawn_area_shape: area_a.to_simple_json_feature} }

        specify 'nomen count' do
          result = Queries::Otu::Filter.new(params).result
          expect(result.count).to eq(6)
        end

        specify 'specific nomen' do
          result = Queries::Otu::Filter.new(params).result
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
          result      = Queries::Otu::Filter.new(params_with).result
          expect(result).to contain_exactly(spooler, cadabra)
        end

        specify 'with same rank' do
          params_with = {nomen_id:    top_dog.taxon_name_id,
                         descendants: '1',
                         rank_class:  'NomenclaturalRank::Iczn::FamilyGroup::Family'}
          result      = Queries::Otu::Filter.new(params_with).result
          expect(result).to contain_exactly(top_dog, by_bill)
        end

        specify 'without rank' do
          params_with = {nomen_id:    top_dog.taxon_name_id,
                         descendants: '1',
                         rank_class: nil}
          result      = Queries::Otu::Filter.new(params_with).result
          expect(result).to contain_exactly(spooler, top_dog, abra, by_bill, cadabra, alakazam)
        end
      end

      specify 'without descendants' do
        params_without = {nomen_id:    top_dog.taxon_name_id,
                          # descendants: nil,
                          rank_class:  'NomenclaturalRank::Iczn::SpeciesGroup::Species'}
        result         = Queries::Otu::Filter.new(params_without).result
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

        tn     = co_a.taxon_names.select { |t| t if t.name == 'cadabra' }.first
        params = {}
        params.merge!({author_ids: [bill.id, daryl.id], and_or_select: '_or_'})
        params.merge!({verbatim_author_string: 'Bill A'})
        params.merge!({geographic_area_ids: [area_a.id]})
        params.merge!({nomen_id:    top_dog.taxon_name_id,
                       descendants: '1',
                       rank_class:  'NomenclaturalRank::Iczn::SpeciesGroup::Species'})

        result = Queries::Otu::Filter.new(params).result
        expect(result).to contain_exactly(tn.otus.first)
      end
    end
  end
end
