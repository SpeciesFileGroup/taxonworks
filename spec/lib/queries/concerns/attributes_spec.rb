require 'rails_helper'

describe Queries::Concerns::Attributes, type: :model, group: [:filter] do

  let(:query) { Queries::CollectingEvent::Filter.new({}) }

  let!(:ce1) { CollectingEvent.create(
    verbatim_locality: 'Out there',
    start_date_year: 2010,
    start_date_month: 2,
    start_date_day: 18)
  }

  let!(:ce2) { CollectingEvent.create(
    verbatim_locality: 'Out there, under the stars',
    verbatim_field_number: 'Foo manchu',
    start_date_year: 2000,
    start_date_month: 2,
    start_date_day: 18,
    print_label: 'THERE: under the stars:18-2-2000') }

  # let!(:namespace) { FactoryBot.create(:valid_namespace, short_name: 'Foo') }
  # let!(:i1) { Identifier::Local::FieldNumber.create!(identifier_object: ce1, identifier: '123', namespace: namespace) }
  # let(:p1) { FactoryBot.create(:valid_person, last_name: 'Smith') }

  context 'wildcard_attribute' do

    specify 'permitted' do
      h = {wildcard_attribute: 'foo'}
      p = ActionController::Parameters.new(h)
      q = Queries::CollectingEvent::Filter.new(p)

      expect(q.params.keys).to include(:wildcard_attribute)
    end

    specify '#start_date_year (integer field test) 1' do
      query.start_date_year = 20
      query.wildcard_attribute = :start_date_year
      expect(query.all.map(&:id)).to contain_exactly(ce1.id, ce2.id)
    end

    specify '#start_date_year (integer field test) 2' do
      query.start_date_year = 2010
      expect(query.all.map(&:id)).to contain_exactly(ce1.id)
    end

    specify '#verbatim_locality (string field test) 1' do
      query.verbatim_locality = 'Out there'
      query.wildcard_attribute = 'verbatim_locality'
      expect(query.all.map(&:id)).to contain_exactly(ce1.id, ce2.id)
    end

    specify '#verbatim_locality (string field test) 2' do
      query.verbatim_locality = 'Out there, '
      expect(query.all.map(&:id)).to contain_exactly()
    end
  end

  specify '#no_value_attribute' do
    query.no_value_attribute = [:print_label]
    expect(query.all).to contain_exactly(ce1)
  end

  specify '#any_value_attribute' do
    query.any_value_attribute = [:print_label]
    expect(query.all).to contain_exactly(ce2)
  end

end
