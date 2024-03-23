require 'rails_helper'

describe Queries::Identifier::Autocomplete, type: :model do

  let(:o1) { FactoryBot.create(:valid_otu) }
  let(:o2) { FactoryBot.create(:valid_specimen) }
  let(:o3) { FactoryBot.create(:valid_collecting_event) }

  let(:n) { FactoryBot.create(:valid_namespace, short_name: 'Foo') }

  let!(:i1) { Identifier::Global::Uri.create!(identifier_object: o1, identifier: 'https://uri.org/example/123') }
  let!(:i2) { Identifier::Local::CatalogNumber.create!(identifier_object: o2, namespace: n, identifier: '345') }
  let!(:i3) { Identifier::Local::CatalogNumber.create!(identifier_object: o3, namespace: n, identifier: '987') }

  let(:query) { Queries::Identifier::Autocomplete.new('') }

  specify '#autocomplete' do
    query.query_string = 'Foo 345'
    expect(query.autocomplete.map(&:id)).to contain_exactly(i2.id)
  end

  specify '#autocomplete_exact_cached' do
    query.query_string = 'Foo 345'
    expect(query.autocomplete_exact_cached.map(&:id)).to contain_exactly(i2.id)
  end

  specify '#autocomplete_exact_identifier' do
    query.query_string = '987'
    expect(query.autocomplete_exact_identifier.map(&:id)).to contain_exactly(i3.id)
  end

  specify '#autocomplete_matching_cached' do
    query.query_string = 'Foo 34'
    expect(query.autocomplete_matching_cached.map(&:id)).to contain_exactly(i2.id)
  end

  specify '#autocomplete_matching_cached_anywhere' do
    query.query_string = '3'
    expect(query.autocomplete_matching_cached_anywhere.map(&:id)).to include(i1.id, i2.id)
  end

end
