require 'rails_helper'

describe Queries::Query do

  let(:query) { Queries::Query::Autocomplete.new({}) }

  before do
    allow(query).to receive(:table) { ::Otu.arel_table }
    allow(query).to receive(:base_query) { ::Otu.select('otus.*') }
  end

  specify '#autocomplete_exact_id 1' do
    query.terms = '123'
    expect(query.autocomplete_exact_id.to_sql).to eq( 'SELECT otus.* FROM "otus" WHERE "otus"."id" = 123 LIMIT 1' )
  end

  specify '#autocomplete_exact_id 2' do
    query.terms = []
    expect(query.autocomplete_exact_id).to eq(nil)
  end

end
