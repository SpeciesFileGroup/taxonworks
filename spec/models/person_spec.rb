require 'spec_helper'

describe Person do
  FactoryGirl.define do
    factory :person do
    end
  end

  let(:person) { FactoryGirl.build(:person) }

  context 'validation' do
    before do
      person.valid?
    end

    specify 'last_name is required' do
      expect(person.errors.keys).to include(:last_name)
    end

    specify "type is required (set to 'Person::Unvetted' when not provided)" do
      expect(person.type).to eq('Person::Unvetted')
    end

    specify 'valid type is either vetted or unvetted' do
      #expect(person.type).to eq('Person::Vetted' or 'Person::Unvetted')
      #expect(['Person::Vetted', 'Person::Unvetted'].include?(person.type)).to be_true
      expect(person.errors.include?(:type)).to be_false
      person.type='funny'
      person.valid?
      expect(person.errors.include?(:type)).to be_true #should have an error
    end
  end

  context 'reflections / foreign keys' do
    context 'has_many' do
      specify 'roles' do
        expect(person).to respond_to(:roles)
      end
    end
  end

  context 'usage and rendering' do

    before do
      @person1 = FactoryGirl.build(:person, first_name: 'J.', last_name: 'Smith')
      @person2 = FactoryGirl.build(:person, first_name: 'J.', last_name: 'McDonald')
      @person3 = FactoryGirl.build(:person, first_name: 'D. Keith McE.', last_name: 'Kevan')
      @person4 = FactoryGirl.build(:person, first_name: 'Ki-Su', last_name: 'Ahn')
    end

    context 'usage' do
      specify 'initials and last name only' do
        expect(@person1.valid?).to be_true
      end

      specify 'camel cased last name and initials' do
        expect(@person2.valid?).to be_true
      end

      specify 'cased last initials and last name only' do
        expect(@person3.valid?).to be_true
      end

      specify 'last name, dashed first name' do
        expect(@person4.valid?).to be_true
      end

      context 'rendering' do
        specify "initials, last name only" do
         expect(@person1.name).to eq("J. Smith")
        end
      end
    end

  end

  context 'roles' do
    specify 'is_author?' do
      person.last_name = 'balloonman'
      expect(person).to respond_to(:is_author?)
      expect(person.is_author?).to be_false
      b = FactoryGirl.create(:bibtex_source)         # Source::Bibtex.new
      b.authors << person
      b.save!
      expect(person.is_author?).to be_true
    end
  end

end
