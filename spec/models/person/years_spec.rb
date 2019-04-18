require 'rails_helper'

describe Person, type: :model, group: :people do

  let(:person) { Person.new }

  let(:source_bibtex) {
    FactoryBot.create(:valid_source_bibtex)
  }

  context 'years' do
    before { person.year_died = 1920 }

    specify 'died after birth' do
      person.year_born = 1930
      person.valid?
      expect(person.errors.include?(:year_born)).to be_truthy
    end

    specify 'not active after death - active start' do
      person.year_active_start = 1930
      person.valid?
      expect(person.errors.include?(:year_active_start)).to be_truthy
    end

    context 'as author/editor' do
      before { person.update(last_name: 'Smith') }

      specify 'active after death as editor - active start' do
        source_bibtex.editors << person
        person.update(year_active_start:  1930)
        person.reload
        person.valid?
        expect(person.errors.include?(:year_active_start)).to be_falsey
      end

      specify 'active after death as author - active start' do
        source_bibtex.authors << person
        person.year_active_start = 1930
        person.reload
        person.valid?
        expect(person.errors.include?(:year_active_start)).to be_falsey
      end
    end

    specify 'not active after death - active end' do
      person.year_active_end = 1930
      person.valid?
      expect(person.errors.include?(:year_active_end)).to be_truthy
    end

    specify 'not active before birth - active start' do
      person.year_born = 1920
      person.year_active_start = 1890
      person.valid?
      expect(person.errors.include?(:year_active_start)).to be_truthy
    end

    specify 'not active before birth - active end' do
      person.year_born = 1920
      person.year_active_end = 1890
      person.valid?
      expect(person.errors.include?(:year_active_end)).to be_truthy
    end

    specify 'lifespan' do
      person.year_born = 1900
      person.year_died = 2020
      person.valid?
      expect(person.errors.include?(:base)).to be_truthy
    end
  end


end
