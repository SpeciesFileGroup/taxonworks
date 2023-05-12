require 'rails_helper'

describe Queries::Source::Autocomplete, type: :model do

  # Authors
  let(:p1) { FactoryBot.create(:valid_person, last_name: 'Smith') }
  let(:p2) { FactoryBot.create(:valid_person, last_name: 'Jones') }
  let(:p3) { FactoryBot.create(:valid_person, last_name: 'Brandt', prefix: 'von') }

  let!(:serial1) { FactoryBot.create(:valid_serial, name: 'Journal of Stuff and Things') }
  let!(:serial2) { FactoryBot.create(:valid_serial, name: 'Journal of Applied Gadgets and Things') }
  let!(:source1) { FactoryBot.create(:valid_source_bibtex, serial_id: serial1.id) }


  let!(:a1) { AlternateValue::Abbreviation.create!(value: 'J. S. and T.', alternate_value_object: serial1, alternate_value_object_attribute: :name) }
  let!(:a2) { AlternateValue::Translation.create!(value: 'Diario de cosas y cosas', language: FactoryBot.create(:valid_language), alternate_value_object: serial1, alternate_value_object_attribute: :name) }
  let!(:a3) { AlternateValue::AlternateSpelling.create!(value: 'Journal of Stuph and Thingz', alternate_value_object: serial1, alternate_value_object_attribute: :name) }

  let(:query) { Queries::Serial::Autocomplete.new(nil, project_id: [project_id]) }

  specify '#autocomplete_exact_name 2' do
    query.terms = 'Journal of Stuff and Things'
    expect(query.autocomplete).to contain_exactly(serial1)
  end

  specify '#autocomplete_begining_name 2' do
    query.terms = 'Journal'
    expect(query.autocomplete).to contain_exactly(serial1, serial2)
  end

  specify '#in_project' do
    query.terms = 'Journal'
    expect(query.autocomplete.map(&:in_project)).to contain_exactly(nil, nil)
    ProjectSource.create(source_id: source1.id)
    expect(query.autocomplete.map(&:in_project)).to contain_exactly(1, nil)
  end

  specify '#autocomplete_exact_name' do
    query.terms = 'Journal of Stuff and Things'
    expect(query.autocomplete_exact_name.map(&:id)).to contain_exactly(serial1.id)
  end

  specify '#autocomplete_begining_name' do
    query.terms = 'Journal'
    expect(query.autocomplete_begining_name.map(&:id)).to contain_exactly(serial1.id, serial2.id)
  end

  specify '#autocomplete_wildcard_name' do
    query.terms = 'of and'
    expect(query.autocomplete_ordered_wildcard_pieces_in_name.map(&:id)).to contain_exactly(serial1.id, serial2.id)
  end

  specify '#autocomplete_exact_alternate_value(,"AlternateValue::AlternateSpelling")' do
    query.terms = 'Journal of Stuph and Thingz'
    expect(query.autocomplete_exact_alternate_value('name', 'AlternateValue::AlternateSpelling').map(&:id)).to contain_exactly(serial1.id)
  end

  specify '#autocomplete_begining_alternate_value' do
    query.terms = 'Journal of Stup'
    expect(query.autocomplete_begining_alternate_value('name', 'AlternateValue::AlternateSpelling').map(&:id)).to contain_exactly(serial1.id)
  end

  specify '#autocomplete_ordered_wildcard_alternate_value' do
    query.terms = 'Stup ngz'
    expect(query.autocomplete_ordered_wildcard_alternate_value('name', 'AlternateValue::AlternateSpelling').map(&:id)).to contain_exactly(serial1.id)
  end

  specify '#autocomplete_exact_alternate_value(,"AlternateValue::Translation")' do
    query.terms = 'Diario de cosas y cosas'
    expect(query.autocomplete_exact_alternate_value('name', 'AlternateValue::Translation').map(&:id)).to contain_exactly(serial1.id)
  end

  specify '#autocomplete_exact_alternate_value(,"AlternateValue::Abbreviation")' do
    query.terms = 'J. S. and T.'
    expect(query.autocomplete_exact_alternate_value('name', 'AlternateValue::Abbreviation').map(&:id)).to contain_exactly(serial1.id)
  end


end
