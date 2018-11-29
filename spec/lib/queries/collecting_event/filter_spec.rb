require 'rails_helper'

describe Queries::CollectingEvent::Filter, type: :model, group: [:collecting_event] do

  let(:query) { Queries::CollectingEvent::Filter.new({}) }

  let!(:ce1) { CollectingEvent.create(verbatim_locality: 'Out there', start_date_year: 2000, start_date_month: 2, start_date_day: 18) }

  let!(:ce2) { CollectingEvent.create(verbatim_locality: 'Out there, under the stars', 
                                      verbatim_trip_identifier: 'Foo manchu',
                                      start_date_year: 2000, 
                                      start_date_month: 2, 
                                      start_date_day: 18,
                                      print_label: 'THERE: under the stars:18-2-2000') }

  # let!(:namespace) { FactoryBot.create(:valid_namespace, short_name: 'Foo') }
  # let!(:i1) { Identifier::Local::TripCode.create!(identifier_object: ce1, identifier: '123', namespace: namespace) }
  # let(:p1) { FactoryBot.create(:valid_person, last_name: 'Smith') }

  specify 'auto added accessors 1' do
    expect(query).to respond_to(:field_notes)
  end

  specify 'attributes are persisted 1' do
    q = Queries::CollectingEvent::Filter.new(field_notes: 'Foo')
    expect(q.field_notes).to eq('Foo')
  end

  specify 'attributes can be set 1' do
    query.field_notes = 'Foo'
    expect(query.field_notes).to eq('Foo')
  end

  specify 'and clauses 1' do
    query.start_date_year = 2000
    expect(query.all).to contain_exactly(ce1, ce2)
  end

  specify 'and clauses 1' do
    query.start_date_year = 2000
    query.start_date_month = 3
    expect(query.all).to contain_exactly()
  end

end
