require 'rails_helper'

describe Queries::Person::Autocomplete, type: :model, group: :people do

  let!(:p1) { Person.create!(last_name: 'Smith') }
  let!(:p2) { Person.create!(last_name: 'Smith', first_name: 'Sarah') }
  let!(:p3) { Person.create!(last_name: 'Brandt', prefix: 'von', first_name: 'Charlie') }
  let!(:p4) { Person.create!(last_name: 'Snopapopalus', first_name: 'George') }
  let!(:p5) { Person.create!(last_name: 'Tártero', first_name: 'Jorgé') }

  let(:query) { Queries::Person::Autocomplete.new('') }

  context 'alternate values' do
    let!(:a1) { AlternateValue::Abbreviation.create!(alternate_value_object: p1, alternate_value_object_attribute: :last_name, value: 'S.') }
    let!(:a2) { AlternateValue::Misspelling.create!(alternate_value_object: p4, alternate_value_object_attribute: :first_name, value: 'Geerge') }
    let!(:a3) { AlternateValue::AlternateSpelling.create!(alternate_value_object: p5, alternate_value_object_attribute: :last_name, value: 'Tartero') }

    specify '1' do
      query.terms = 'S.'
      expect(query.autocomplete_alternate_values_last_name.map(&:id)).to contain_exactly(p1.id)
    end

    specify '2' do
      query.terms = 'Geerge'
      expect(query.autocomplete_alternate_values_first_name.map(&:id)).to contain_exactly(p4.id)
    end

    specify '3' do
      query.terms = 'Tartero'
      expect(query.autocomplete.map(&:id)).to contain_exactly(p5.id)
    end
  end

  specify '#normalize 1' do
    expect(query.normalize('Smith, Sarah')).to eq('Smith, Sarah')
  end

  specify '#normalize 1' do
    query.terms = 'Sarah Smith'
    expect(query.invert_name).to eq('Smith, Sarah')
  end

  specify '#autocomplete_exact_match 1' do
    query.terms = 'Tártero, Jorgé'
    expect(query.autocomplete_exact_match.map(&:id).first).to eq(p5.id)
  end

  specify '#autocomplete_exact_match 2' do
    query.terms = 'Smith, Sarah'
    expect(query.autocomplete_exact_match.map(&:id).first).to eq(p2.id)
  end

  specify '#autocomplete_exact_match 3' do
    query.terms = 'Smith,Sarah'
    expect(query.autocomplete_exact_match.map(&:id).first).to eq(p2.id)
  end

  specify '#autocomplete_exact_match 4' do
    query.terms = ' Smith,   Sarah  '
    expect(query.autocomplete_exact_match.map(&:id).first).to eq(p2.id)
  end

  specify 'autocomplete_exact_inverted 1' do
    query.terms = 'Sarah Smith'
    expect(query.autocomplete_exact_inverted.map(&:id).first).to eq(p2.id)
  end

  specify '#autocomplete_cached_wildcard_anywhere 1' do
    query.terms = 'Smith Sarah'
    expect(query.autocomplete_cached_wildcard_anywhere.map(&:id).first).to eq(p2.id)
  end

  specify '#autocomplete_cached_wildcard_anywhere 2' do
    query.terms = 'Sarah Smith'
    expect(query.autocomplete_cached_wildcard_anywhere.map(&:id).first).to eq(p2.id)
  end

  specify '#autocomplete_cached' do
    query.terms = 'Smith'
    expect(query.autocomplete_cached.pluck(:id)).to contain_exactly(p1.id, p2.id)
  end

  context 'roles' do
    let!(:collecting_event) { CollectingEvent.create(verbatim_locality: 'Neverland', collectors: [p2]) }

    before do
      query.terms = 'Smith'
    end

    specify 'if no roles provided all for project' do
      expect(query.autocomplete.map(&:id)).to contain_exactly(p1.id, p2.id)
    end

    specify 'project, no roles' do
      query.project_id = 1
      expect(query.autocomplete.map(&:id)).to contain_exactly(p1.id, p2.id)
    end

    specify 'roles, no project' do
      query.limit_to_roles = ['Collector']
      expect(query.autocomplete.map(&:id)).to contain_exactly(p2.id)
    end

    specify 'roles, project' do
      query.project_id = 1
      query.limit_to_roles = ['Collector']
      expect(query.autocomplete.map(&:id)).to contain_exactly(p2.id)
    end
  end
end
