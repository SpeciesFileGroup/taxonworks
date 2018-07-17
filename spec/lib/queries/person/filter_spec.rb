require 'rails_helper'

describe Queries::Person::Filter, type: :model do

  let!(:p1) { Person.create!(last_name: 'Smith') }
  let!(:p2) { Person.create!(last_name:  'Smith',
                             first_name: 'Sarah') }
  let!(:p3) { Person.create!(last_name:  'Brandt',
                             prefix:     'von',
                             first_name: 'Charlie') }
  let!(:p4) { Person.create!(last_name:  'Snopapopalus',
                             first_name: 'George') }
  let!(:p5) { Person.create!(last_name:  'Bundy',
                             first_name: 'Ted') }

  let(:query) { Queries::Person::Filter.new('') }

  let!(:collecting_event) {
    CollectingEvent.create(verbatim_locality:               'Neverland',
                           with_verbatim_data_georeference: true,
                           verbatim_latitude:               '10',
                           verbatim_longitude:              '10',
                           collectors:                      [p2])
  }
  let!(:georeference) {
    collecting_event.georeferences.first.georeferencers << p3
    collecting_event.georeferences.first.georeferencers << p2
  }

  context 'partial name only' do
    context 'containing \'a\'' do
      specify 'with role' do
        params = {lastname: '', firstname: 'a', roles: ['Collector']}
        expect(Queries::Person::Filter.new(params).partial_complete)
          .to contain_exactly(p2.becomes(Person::Vetted))
      end

      specify 'without role' do
        params = {lastname: '', firstname: 'a', roles: []}
        expect(Queries::Person::Filter.new(params).partial_complete)
          .to contain_exactly(p3.becomes(Person::Unvetted),
                              p2.becomes(Person::Vetted),
                              p4.becomes(Person::Unvetted))
      end
    end
  end

  context 'exact name' do
    context 'containing \'Smitha\'' do
      specify 'with role' do
        params = {lastname: 'Smith', firstname: '', roles: ['Collector']}
        expect(Queries::Person::Filter.new(params).all)
          .to contain_exactly(p2.becomes(Person::Vetted))
      end

      specify 'without role' do
        params = {lastname: 'Smith', firstname: '', roles: []}
        expect(Queries::Person::Filter.new(params).all)
          .to contain_exactly(p2.becomes(Person::Vetted),
                              p1.becomes(Person::Unvetted))
      end
    end
  end

  context 'exact first name, last_name' do
    context 'containing \'Smith, Sarah\'' do
      specify 'with role' do
        params = {lastname: 'Smith', firstname: 'Sarah', roles: ['Collector']}
        expect(Queries::Person::Filter.new(params).all)
          .to contain_exactly(p2.becomes(Person::Vetted))
      end

      specify 'without role' do
        params = {lastname: 'Smith', firstname: 'Sarah', roles: []}
        expect(Queries::Person::Filter.new(params).all)
          .to contain_exactly(p2.becomes(Person::Vetted))
      end
    end
  end

  context 'partial_complete' do
    context 'wildcard' do
      context 'last name' do
        specify 'smi*' do
          params = {lastname: 'smi*'}
          expect(Queries::Person::Filter.new(params).partial_complete)
            .to contain_exactly(p2.becomes(Person::Vetted),
                                p1.becomes(Person::Unvetted))
        end
      end

      context 'first name' do
        specify 'sa*' do
          params = {firstname: 'sa*'}
          expect(Queries::Person::Filter.new(params).partial_complete)
            .to contain_exactly(p2.becomes(Person::Vetted))
        end
      end
    end

    context 'partial' do
      context 'last name' do
        specify 'mit' do
          params = {lastname: 'mit'}
          expect(Queries::Person::Filter.new(params).partial_complete)
            .to contain_exactly(p2.becomes(Person::Vetted),
                                p1.becomes(Person::Unvetted))
        end
      end
    end
  end

  context 'roles' do
    specify 'with role' do
      params = {lastname: '', firstname: '', roles: ['Collector']}
      expect(Queries::Person::Filter.new(params).all)
        .to contain_exactly(p2.becomes(Person::Vetted))
    end

    specify 'with multiple roles' do
      params = {lastname: '', firstname: '', roles: ['Collector', 'Georeferencer']}
      expect(Queries::Person::Filter.new(params).all)
        .to contain_exactly(p3.becomes(Person::Unvetted),
                            p2.becomes(Person::Vetted))
    end

    specify 'without role' do
      params = {lastname: '', firstname: '', roles: []}
      expect(Queries::Person::Filter.new(params).all)
        .to contain_exactly(p2.becomes(Person::Vetted),
                            p1.becomes(Person::Unvetted),
                            p3.becomes(Person::Unvetted),
                            p4.becomes(Person::Unvetted),
                            p5.becomes(Person::Unvetted))
    end
  end
end
