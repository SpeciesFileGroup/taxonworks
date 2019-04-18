require 'rails_helper'

describe Queries::Person::Filter, type: :model, group: :people do

  let!(:p1) { Person.create!(last_name: 'Smith') }
  let!(:p2) { Person.create!(last_name:  'Smith',
                             first_name: 'Sarah') }
  let!(:p3) { Person.create!(last_name:  'Brandt',
                             prefix:     'von',
                             first_name: 'Charlie') }
  let!(:p4) { Person.create!(last_name:  'Snopapopalus',
                             first_name: 'George') }
  let!(:p5) { Person.create!(last_name:  'Bundy',
                             first_name: 'Al') }

  let!(:collecting_event) {
    CollectingEvent.create!(
      verbatim_locality: 'Neverland',
      with_verbatim_data_georeference: true,
      verbatim_latitude: '10',
      verbatim_longitude: '10',
      collectors: [p2])
  }

  let!(:georeference) {
    collecting_event.georeferences.first.georeferencers << p3
    collecting_event.georeferences.first.georeferencers << p2
  }

  let(:query) { Queries::Person::Filter.new({}) }

  specify '#last_name_starting_with' do
    query.last_name_starts_with = 'S'
    expect(query.all.pluck(:id)).to contain_exactly(p1.id, p2.id, p4.id)
  end

  # TODO: discuss a default strategy
  specify 'without params nothing is returned' do 
    expect(query.all.pluck(:id)).to contain_exactly(p1.id, p2.id, p3.id, p4.id, p5.id)
  end

  context 'partial name only' do
    context "containing 'a'" do
      specify 'with role' do
        query.first_name = 'a'
        query.limit_to_roles = %w{Collector}
        expect(query.all.pluck(:id)).to contain_exactly(p2.id)
      end

      specify 'without role' do
        query.first_name = 'a'
        expect(query.all.pluck(:id)).to contain_exactly(p2.id, p3.id, p5.id)
      end
    end
  end

  context 'full name' do
    context "containing 'Smith'" do
      specify 'with role' do
        query.last_name = 'Smith'
        query.limit_to_roles = %w{Collector}
        expect(query.all.pluck(:id)).to contain_exactly(p2.id)
      end

      specify 'without role' do
        query.last_name = 'Smith'
        expect(query.all.pluck(:id)).to contain_exactly(p1.id, p2.id)
      end
    end
  end

  context 'exact first name, last_name' do
    context "containing 'Smith, Sarah'" do
      specify 'with role' do
        query.last_name = 'Smith'
        query.first_name = 'Sarah'
        query.limit_to_roles = %w{Collector}
        expect(query.all.map(&:id)).to contain_exactly(p2.id) 
      end

      specify 'without role' do
        params = {last_name: 'Smith', first_name: 'Sarah', roles: []}
        expect(Queries::Person::Filter.new(params).all)
          .to contain_exactly(p2.becomes(Person::Vetted))
      end
    end
  end

  # Largely redundant
  context 'partial_complete' do
    context 'last name only' do
      specify 'smi' do
        params = {last_name: 'smi'}
        expect(Queries::Person::Filter.new(params).all)
          .to contain_exactly(p1.becomes(Person::Unvetted),
                              p2.becomes(Person::Vetted))
      end

      specify 'u' do
        params = {last_name: 'u'}
        expect(Queries::Person::Filter.new(params).all)
          .to contain_exactly(p5.becomes(Person::Unvetted),
                              p4.becomes(Person::Unvetted))
      end
    end

    context 'first name only' do
      specify 'sa' do
        params = {first_name: 'sa'}
        expect(Queries::Person::Filter.new(params).all)
          .to contain_exactly(p2.becomes(Person::Vetted))
      end

      specify 'e' do
        query.first_name = 'e'
        expect(query.all.map(&:id)).to contain_exactly(p3.id, p4.id)
      end
    end

    context 'first and last' do
      specify 'sa smi' do
        params = {first_name: 'sa', last_name: 'smi'}
        expect(Queries::Person::Filter.new(params).all)
          .to contain_exactly(p2.becomes(Person::Vetted))
      end
    end
  end

  context 'roles' do
    specify 'with role' do
      params = {roles: ['Collector']}
      expect(Queries::Person::Filter.new(params).all.map(&:id)).to contain_exactly(p2.id)
    end

    specify 'with multiple roles' do
      params = {roles: ['Collector', 'Georeferencer']}
      expect(Queries::Person::Filter.new(params).all.pluck(:id)).to contain_exactly(p2.id, p3.id)
    end
  end

end
