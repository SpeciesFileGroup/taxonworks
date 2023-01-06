require 'rails_helper'

describe Queries::Query do

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

end
