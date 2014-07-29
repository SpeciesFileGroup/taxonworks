require 'rails_helper'

describe Source::Human, :type => :model do

  let(:source_human) { Source::Human.new }

  context 'associations' do

    skip 'does authority work correctly?' # all author last names.
    context 'has_many' do
      skip 'with multiple authors - is the ordering correct'

    end

    context 'belongs_to' do

    end

    context 'has_one' do
      context 'person' do
        specify 'responds to :people' do
          expect(source_human).to respond_to(:people)
        end

        specify 'add a person, save the source' do
          p1 = FactoryGirl.create(:valid_person)
          expect(source_human.save).to be_truthy
          expect(source_human.people << p1).to be_truthy   #must have source & person must be saved before << operator
          expect(source_human.people.first).to eq(p1.becomes(Person::Unvetted))
          expect(source_human.save).to be_truthy
        end
      end
      specify 'source_source' do
        expect(source_human).to respond_to(:source_source_roles)
      end
      specify 'role' do
        expect(source_human).to respond_to(:roles)
      end
    end

  end

  context 'validation' do

  end

  specify 'create person with role of human source'

  specify 'a source_human should have a person'
  specify 'a source_source role should have a source'

  skip 'are the cached values set correctly'


end
