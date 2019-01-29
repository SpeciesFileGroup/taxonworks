require 'rails_helper'

describe Queries::CollectionObject::Filter, type: :model, group: [:collecting_event] do

  let(:query) { Queries::CollectionObject::Filter.new({}) }

  let(:ce1) { CollectingEvent.create(verbatim_locality: 'Out there', start_date_year: 2010, start_date_month: 2, start_date_day: 18) }

  let(:ce2) { CollectingEvent.create(verbatim_locality: 'Out there, under the stars', 
                                      verbatim_trip_identifier: 'Foo manchu',
                                      start_date_year: 2000, 
                                      start_date_month: 2, 
                                      start_date_day: 18,
                                      print_label: 'THERE: under the stars:18-2-2000') }


  let!(:co1) { Specimen.create!(collecting_event: ce1) }

  # let!(:namespace) { FactoryBot.create(:valid_namespace, short_name: 'Foo') }
  # let!(:i1) { Identifier::Local::TripCode.create!(identifier_object: ce1, identifier: '123', namespace: namespace) }
  # let(:p1) { FactoryBot.create(:valid_person, last_name: 'Smith') }
  specify '#recent' do
    query.recent = 1 
    expect(query.all.map(&:id)).to contain_exactly(co1.id)
  end
end
