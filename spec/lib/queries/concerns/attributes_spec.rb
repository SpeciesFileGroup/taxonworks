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
    start_date_day: 7,
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

  context 'wildcard_pairs' do
    before(:each) do
      FactoryBot.create(:valid_collecting_event) # not this
    end

    specify '1 attr, 1 wildcard value' do
      query.attribute_wildcard_pair = 'verbatim_locality:Out there'

      expect(query.all.map(&:id)).to contain_exactly(ce1.id, ce2.id)
    end

     specify '1 attr, 2 wildcard values (or)' do
      query.attribute_wildcard_pair =
        ['verbatim_locality:there', 'verbatim_locality:stars']
      expect(query.all.map(&:id)).to contain_exactly(ce1.id, ce2.id)
    end

    specify '1 attr, 3 values (2 or wildcard, 1 and exact)' do
      query.attribute_wildcard_pair =
        ['verbatim_locality:there', 'verbatim_locality:stars']
      query.attribute_exact_pair =
        'verbatim_locality:Out there, under the stars'
      expect(query.all.map(&:id)).to contain_exactly(ce2.id)
    end

    specify '1 attr, 2 exact or' do
      query.attribute_exact_pair =
        ['start_date_day:7', 'start_date_day:18']

      expect(query.all.map(&:id)).to contain_exactly(ce1.id, ce2.id)
    end

    specify '2 attr, 2 wildcard or, 1 exact' do
      query.attribute_wildcard_pair =
        ['start_date_day:7', 'start_date_day:18']
      query.attribute_exact_pair =
        'verbatim_locality:Out there, under the stars'

      expect(query.all.map(&:id)).to contain_exactly(ce2.id)
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

  context 'row-based attribute facet' do
    let!(:ce3) { CollectingEvent.create(
      verbatim_locality: 'Elsewhere',
      print_label: 'Label 3')
    }

    specify 'exact match' do
      query.set_attributes_params(
        attribute_name: ['verbatim_locality'],
        attribute_value: ['Out there'],
        attribute_value_type: ['exact'],
        attribute_value_negator: [false],
        attribute_combine_logic: [nil]
      )

      expect(query.all).to contain_exactly(ce1)
    end

    specify 'wildcard match' do
      query.set_attributes_params(
        attribute_name: ['verbatim_locality'],
        attribute_value: ['Out there'],
        attribute_value_type: ['wildcard'],
        attribute_value_negator: [false],
        attribute_combine_logic: [nil]
      )

      expect(query.all).to contain_exactly(ce1, ce2)
    end

    specify 'negated exact excludes matching value' do
      query.set_attributes_params(
        attribute_name: ['verbatim_locality'],
        attribute_value: ['Out there'],
        attribute_value_type: ['exact'],
        attribute_value_negator: [true],
        attribute_combine_logic: [nil]
      )

      expect(query.all).to contain_exactly(ce2, ce3)
    end

    specify 'any and no value types' do
      query.set_attributes_params(
        attribute_name: ['print_label', 'print_label'],
        attribute_value: ['ignored', 'ignored'],
        attribute_value_type: ['any', 'no'],
        attribute_value_negator: [false, false],
        attribute_combine_logic: [true, nil]
      )

      expect(query.all).to contain_exactly(ce1, ce2, ce3)
    end

    specify 'combine logic left-to-right' do
      query.set_attributes_params(
        attribute_name: ['verbatim_locality', 'print_label'],
        attribute_value: ['Out there', 'ignored'],
        attribute_value_type: ['wildcard', 'any'],
        attribute_value_negator: [false, false],
        attribute_combine_logic: [nil, nil]
      )

      expect(query.all).to contain_exactly(ce2)
    end

    specify 'combine logic AND NOT' do
      query.set_attributes_params(
        attribute_name: ['verbatim_locality', 'print_label'],
        attribute_value: ['Out there', 'ignored'],
        attribute_value_type: ['exact', 'any'],
        attribute_value_negator: [false, false],
        attribute_combine_logic: [false, nil]
      )

      expect(query.all).to contain_exactly(ce1)
    end

    specify 'combine logic OR' do
      query.set_attributes_params(
        attribute_name: ['verbatim_locality', 'print_label'],
        attribute_value: ['Out there', 'Label 3'],
        attribute_value_type: ['exact', 'exact'],
        attribute_value_negator: [false, false],
        attribute_combine_logic: [true, nil]
      )

      expect(query.all).to contain_exactly(ce1, ce3)
    end

    specify 'chained logic left-to-right' do
      query.set_attributes_params(
        attribute_name: ['print_label', 'verbatim_locality', 'print_label'],
        attribute_value: ['ignored', 'Out there', 'Label 3'],
        attribute_value_type: ['any', 'exact', 'exact'],
        attribute_value_negator: [false, false, false],
        attribute_combine_logic: [true, false, nil]
      )

      expect(query.all).to contain_exactly(ce1, ce2)
    end
  end

end
