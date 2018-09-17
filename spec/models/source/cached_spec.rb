require 'rails_helper'

describe Source, type: :model, group: :sources do


  let(:source) { Source::Bibtex.new(title: 'Bears in the woods',
                                    bibtex_type: 'article',
                                    year: 1776,
                                    month: 7,
                                    day: 4) }
  let(:person1) { Person.create!(last_name: 'Smith') }
  let(:person2) { Person.create!(last_name: 'Jones') }
  let(:person3) { Person.create!(last_name: 'Hammerstein') }


  context 'after save' do
    before do
      source.author_roles.build(person: person1)
      source.author_roles.build(person: person2)
      source.author_roles.build(person: person3)
      source.save!
    end

    specify '#cached' do
      expect(source.cached).to match('Smith, Jones & Hammerstein')
    end

    specify '#cached_author_string' do
      expect(source.cached_author_string).to eq('Smith, Jones & Hammerstein')
    end

    specify '#cached_nomenclature_date' do
      expect(source.cached_nomenclature_date.to_s).to eq('1776-07-04')
    end
  end

end
