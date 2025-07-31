require 'rails_helper'

describe Queries::CollectingEvent::Autocomplete, type: :model do

  let(:query) { Queries::CollectingEvent::Autocomplete.new('') }

  let!(:ce1) { CollectingEvent.create(
    verbatim_locality: 'Out there',
    start_date_year: 2000,
    start_date_month: 2,
    start_date_day: 18) }

  let!(:ce2) { CollectingEvent.create(
    verbatim_locality: 'Out there, under the stars',
    verbatim_field_number: 'Foo manchu',
    start_date_year: 2000,
    start_date_month: 2,
    start_date_day: 19,
    end_date_day: 22,
    end_date_month: 4,
    end_date_year: 2000,
    verbatim_date: 'ii/18/2000',
    verbatim_latitude: '12.12',
    verbatim_longitude: '34.34',
    verbatim_collectors: 'Jones, A.B.',
    verbatim_habitat: 'parkland',
    print_label: 'THERE: under the stars:18-2-2000',
    collector_roles_attributes: [{person_attributes: {last_name: 'Jones'}}]
  ) }

  let!(:namespace) { FactoryBot.create(:valid_namespace, short_name: 'Foo') }
  let!(:i1) { Identifier::Local::FieldNumber.create!(identifier_object: ce1, identifier: '123', namespace:) }

  let(:p1) { FactoryBot.create(:valid_person, last_name: 'Smith') }

  specify '#autocomplete_cached_wildcard_anywhere' do
    query.terms = '2000 there'
    expect(query.autocomplete_cached_wildcard_anywhere.map(&:id)).to contain_exactly(ce2.id, ce1.id)
  end

  specify '#autocomplete_verbatim_latitude_or_longitude 1' do
    query.terms = '12.12'
    expect(query.autocomplete_verbatim_latitude_or_longitude.map(&:id)).to contain_exactly(ce2.id)
  end

  specify '#autocomplete_verbatim_latitude_or_longitude 2' do
    query.terms = '.34'
    expect(query.autocomplete_verbatim_latitude_or_longitude.map(&:id)).to contain_exactly(ce2.id)
  end

  specify '#autocomplete_verbatim_locality_wildcard_end_starting_year' do
    query.terms = 'Out there, unde 2000'
    expect(query.autocomplete_verbatim_locality_wildcard_end_starting_year.map(&:id)).to contain_exactly(ce2.id)
  end

  specify '#autocomplete_verbatim_date' do
    query.terms = 'ii/18'
    expect(query.autocomplete_verbatim_date.map(&:id)).to contain_exactly(ce2.id)
  end

  specify '#autocomplete_verbatim_locality_wildcard_end' do
    query.terms = 'Out there, unde'
    expect(query.autocomplete_verbatim_locality_wildcard_end.map(&:id)).to contain_exactly(ce2.id)
  end

  specify '#autocomplete_verbatim_locality_wildcard_end 2 (too short)' do
    query.terms = 'Out'
    expect(query.autocomplete_verbatim_locality_wildcard_end).to eq(nil)
  end

  specify '#autocomplete_verbatim_field_number_match (:cached)' do
    query.terms = 'foo manchu'
    expect(query.autocomplete_verbatim_field_number_match.map(&:id)).to contain_exactly(ce2.id)
  end

  specify '#autocomplete_identifier_cached_exact' do
    query.terms = 'Foo 123'
    expect(query.autocomplete_identifier_cached_exact.map(&:id)).to contain_exactly(ce1.id)
  end

  specify '#autocomplete_identifier_cached_like' do
    query.terms = 'oo 12'
    expect(query.autocomplete_identifier_cached_like.map(&:id)).to contain_exactly(ce1.id)
  end

  specify '#autocomplete_start_or_end_date 1' do
    query.terms = 'ZZZ 19/2/2000 QQQ'
    expect(query.autocomplete_start_or_end_date.map(&:id)).to contain_exactly(ce2.id)
  end

  specify '#autocomplete_start_or_end_date 2' do
    query.terms = '2000-2-18'
    expect(query.autocomplete_start_or_end_date.map(&:id)).to contain_exactly(ce1.id)
  end

  specify '#autocomplete_start_or_end_date 2' do
    query.terms = '2000-4-22'
    expect(query.autocomplete_start_or_end_date.map(&:id)).to contain_exactly(ce2.id)
  end

  specify '#autocomplete_start_date_wild_card (:verbatim_locality)' do
    query.terms = 'under the stars 19/2/2000'
    expect(query.autocomplete_start_date_wild_card.map(&:id)).to contain_exactly(ce2.id)
  end

  specify '#autocomplete_start_date_wild_card (:verbatim_locality)' do
    query.terms = 'under the stars 19-2-2000'
    expect(query.autocomplete_start_date_wild_card.map(&:id)).to contain_exactly(ce2.id)
  end

  specify '#autocomplete_start_date_wild_card (:verbatim_locality)' do
    query.terms = 'under the stars 2000-2-19'
    expect(query.autocomplete_start_date_wild_card.map(&:id)).to contain_exactly(ce2.id)
  end

  specify '#autocomplete_start_date_wild_card (:verbatim_locality)' do
    query.terms = '2000-2-18'
    expect(query.autocomplete_start_date_wild_card).to eq(nil)
  end

  specify '#autocomplete_start_date_wild_card (:cached)' do
    query.terms = 'under the stars 19/2/2000'
    expect(query.autocomplete_start_date_wild_card(:cached).map(&:id)).to contain_exactly(ce2.id)
  end

  specify '#autocomplete_verbatim_collectors_wildcard' do
    query.terms = 'Jones'
    expect(query.autocomplete_verbatim_collectors_wildcard.map(&:id)).to contain_exactly(ce2.id)
  end

  specify '#autocomplete_verbatim_collectors_wildcard' do
    query.terms = 'Jones'
    expect(query.autocomplete_verbatim_collectors_wildcard.map(&:id)).to contain_exactly(ce2.id)
  end

  specify '#autocomplete_matching_collectors' do
    query.terms = 'Jones'
    expect(query.autocomplete_matching_collectors.map(&:id)).to contain_exactly(ce2.id)
  end

  specify '#autocomplete_verbatim_habitat' do
    query.terms = 'parkland'
    expect(query.autocomplete_verbatim_habitat.map(&:id)).to contain_exactly(ce2.id)
  end

end
