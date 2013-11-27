require 'spec_helper'

describe Role do
  let(:role) { Role.new }

  context 'validation' do
    before do
      role.valid?
    end

    context 'required fields' do
      specify 'person_id' do
        expect(role.errors.include?(:person_id)).to be_true
      end
      specify 'type' do
        expect(role.errors.include?(:type)).to be_true
      end
      specify 'role_object_id' do
        expect(role.errors.include?(:role_object_id)).to be_true
      end
      specify 'role_object_type' do
        expect(role.errors.include?(:role_object_type)).to be_true
      end
    end

    context 'indices' do
      specify 'one person can not have two identical roles' do
        person = FactoryGirl.create(:valid_person)
        role_object = FactoryGirl.create(:valid_bibtex_source)
        role1 = Role.new(person: person, role_object:  role_object, type: 'SourceAuthor')
        expect(role1.valid?).to be_true
        role1.save
        role2 = Role.new(person: person, role_object:  role_object, type: 'SourceAuthor')
        expect(role2.valid?).to be_false
        expect(role2.errors.include?(:person_id)).to be_true
      end
    end

    context('after save') {
      author_role = FactoryGirl.create(:source_author_role)
      specify 'position is specified by acts_as_list' do
        expect(author_role.position).to eq(1)
      end
    }
  end

  context "reflections / foreign keys" do
    context "belongs_to" do
      specify "person" do
        expect(role).to respond_to(:person)
      end
    end
  end

end
