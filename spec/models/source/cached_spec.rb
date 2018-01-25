require 'rails_helper'

describe Source, type: :model, group: :sources do


  let(:source) { Source::Bibtex.new(title: 'Bears in the woods', bibtex_type: 'article') }
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

  end

end
