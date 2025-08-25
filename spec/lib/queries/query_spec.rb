require 'rails_helper'

describe Queries::Query, type: :model do

  let(:query) { Queries::Query.new }

  before do
    allow(query).to receive(:table) { ::Otu.arel_table }
    allow(query).to receive(:base_query) { ::Otu.select('otus.*') }
  end

  specify '#query_string' do
    expect(query.query_string).to eq(nil)
  end

  specify '#terms' do
    expect(query.terms).to eq([])
  end

  specify '#no_terms?' do
    expect(query.no_terms?).to be_truthy
  end

  specify '#terms= builds @terms' do
    query.terms = 'a b c'
    expect(query.terms).to contain_exactly('a b c%', '%a b c%')
  end

  # See spec/lib/queries/otu/filter_spec.rb for base_query and table specs

  context '.union' do
    let!(:o1) { FactoryBot.create(:valid_otu) }
    let!(:o2) { FactoryBot.create(:valid_otu) }
    let!(:o3) { FactoryBot.create(:valid_otu) }
    let(:q1) { Otu.where(id: [o1.id, o2.id]) }
    let(:q2) { Otu.where(id: [o1.id, o3.id]) }
    let(:qcross) { Otu.joins('LEFT OUTER JOIN otus AS o ON 1 = 1') } # 9 results
    let(:query) { Queries::Otu::Filter.new({}) }

    specify '0 queries' do
      expect(query.referenced_klass_union([]).map(&:id)).to contain_exactly(o1.id, o2.id, o3.id)
    end

    specify '1 query, distinct results' do
      expect(query.referenced_klass_union([qcross]).map(&:id)).to contain_exactly(o1.id, o2.id, o3.id)
    end

    specify '2 queries, distinct results' do
      expect(query.referenced_klass_union([q1, q2]).map(&:id)).to contain_exactly(o1.id, o2.id, o3.id)
    end

    specify '2 queries, one None, distinct results' do
      expect(qcross.count).to eq(9)
      expect(query.referenced_klass_union([qcross, Otu.none]).map(&:id)).to contain_exactly(o1.id, o2.id, o3.id)
    end
  end
end
