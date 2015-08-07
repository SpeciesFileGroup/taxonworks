require 'rails_helper'

describe Role, :type => :model do
  let(:role) { Role.new }
  let(:person) { FactoryGirl.create(:valid_person) }

  context 'validation' do
    before do
      role.valid?
    end

    context 'required' do
      specify 'person' do
        expect(role.errors.include?(:person)).to be_truthy
      end

      specify 'role_object' do
        expect(role.errors.include?(:person)).to be_truthy
      end
 
      specify 'type' do
        expect(role.errors.include?(:type)).to be_truthy
     end
    end

    context 'indices' do
      specify 'one person can not have two identical roles' do
        role_object = FactoryGirl.create(:valid_source_bibtex)
        role1 = Role.new(person: person, role_object:  role_object, type: 'SourceAuthor')
        expect(role1.valid?).to be_truthy
        role1.save
        role2 = Role.new(person: person, role_object:  role_object, type: 'SourceAuthor')
        expect(role2.valid?).to be_falsey
        expect(role2.errors.include?(:person_id)).to be_truthy
      end
    end

    context 'after save' do 
      specify 'position is specified by acts_as_list' do
        @author_role = FactoryGirl.build(:valid_source_author)
        @author_role.save
        expect(@author_role.position).to eq(1)
      end

      context 'auto-vetting people' do
        let(:collecting_event) { FactoryGirl.create(:valid_collecting_event) }
        let(:other_collecting_event) { FactoryGirl.create(:valid_collecting_event) }
        
        before {
          collecting_event.collectors << person
        }

        specify 'a person with a single role is not vetted' do
          expect(person.roles(false).size).to eq(1)
          expect(person.reload.type).to eq('Person::Unvetted')
        end

        specify 'a person with two roles becomes vetted' do
          other_collecting_event.collectors << person
          expect(person.roles(false).size).to eq(2)
          expect(person.reload.type).to eq('Person::Vetted')
        end
      end
    end 
  end

  context "associations" do
    context "belongs_to" do
      specify "person" do
        expect(role).to respond_to(:person)
      end
    end
  end

  context 'concerns' do
    it_behaves_like 'is_data'
  end

end
