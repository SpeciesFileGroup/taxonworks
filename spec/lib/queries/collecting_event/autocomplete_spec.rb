require 'rails_helper'

describe Queries::CollectingEvent::Autocomplete, type: :model do

  let!(:ce1) { CollectingEvent.create(verbatim_locality: 'Out there', start_date_year: 2000, start_date_month: 2, start_date_day: 18) }

  let!(:ce2) { CollectingEvent.create(verbatim_locality: 'Out there, under the stars', 
                                      verbatim_trip_identifier: 'Foo manchu',
                                      start_date_year: 2000, 
                                      start_date_month: 2, 
                                      start_date_day: 18,
                                      print_label: 'THERE: under the stars:18-2-2000') }

  let!(:namespace) { FactoryBot.create(:valid_namespace, short_name: 'Foo') }

  let!(:i1) { Identifier::Local::TripCode.create!(identifier_object: ce1, identifier: '123', namespace: namespace) }

  let(:query) { Queries::CollectingEvent::Autocomplete.new('') }

  let(:p1) { FactoryBot.create(:valid_person, last_name: 'Smith') }


  specify '#autocomplete_cached_wildcard_anywhere' do
    query.terms = '2000 there'
    expect(query.autocomplete_cached_wildcard_anywhere.map(&:id)).to contain_exactly(ce2.id, ce1.id)
  end

  specify '#autocomplete_verbatim_locality_wildcard_end_starting_year' do
    query.terms = 'Out there, unde 2000' 
    expect(query.autocomplete_verbatim_locality_wildcard_end_starting_year.map(&:id)).to contain_exactly(ce2.id)
  end

  specify '#autocomplete_verbatim_locality_wildcard_end' do
    query.terms = 'Out there, unde' 
    expect(query.autocomplete_verbatim_locality_wildcard_end.map(&:id)).to contain_exactly(ce2.id)
  end

  specify '#autocomplete_verbatim_locality_wildcard_end 2 (too short)' do
    query.terms = 'Out t' 
    expect(query.autocomplete_verbatim_locality_wildcard_end).to eq(nil)
  end

  specify '#autocomplete_verbatim_trip_identifier_match (:cached)' do
    query.terms = 'foo manchu' 
    expect(query.autocomplete_verbatim_trip_identifier_match.map(&:id)).to contain_exactly(ce2.id)
  end

  specify '#autocomplete_identifier_cached_exact' do
    query.terms = 'Foo 123' 
    expect(query.autocomplete_identifier_cached_exact.map(&:id)).to contain_exactly(ce1.id)
  end

  specify '#autocomplete_identifier_cached_like' do
    query.terms = 'oo 12' 
    expect(query.autocomplete_identifier_cached_like.map(&:id)).to contain_exactly(ce1.id)
  end

  specify '#autocomplete_start_date 1' do
    query.terms = 'foo bar 18/2/2000 stuff' 
    expect(query.autocomplete_start_date.map(&:id)).to contain_exactly(ce1.id, ce2.id)
  end

  specify '#autocomplete_start_date_wild_card (:verbatim_locality)' do
    query.terms = 'under the stars 18/2/2000' 
    expect(query.autocomplete_start_date_wild_card.map(&:id)).to contain_exactly(ce2.id)
  end

  specify '#autocomplete_start_date_wild_card (:cached)' do
    query.terms = 'under the stars 18/2/2000' 
    expect(query.autocomplete_start_date_wild_card(:cached).map(&:id)).to contain_exactly(ce2.id)
  end


end
