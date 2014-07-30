require 'rails_helper'

describe Role, :type => :model do
  let(:role) { Role.new }

  context 'validation' do
    before do
      role.valid?
    end

    context 'required fields' do
      specify 'person_id' do
        expect(role.errors.include?(:person_id)).to be_truthy
      end
      specify 'type' do
        expect(role.errors.include?(:type)).to be_truthy
      end
      specify 'role_object_id' do
        expect(role.errors.include?(:role_object_id)).to be_truthy
      end
      specify 'role_object_type' do
        expect(role.errors.include?(:role_object_type)).to be_truthy
      end
    end

    context 'indices' do
      before(:each) {
        @person = FactoryGirl.create(:valid_person)
      }

      specify 'one person can not have two identical roles' do
        role_object = FactoryGirl.create(:valid_source_bibtex)
        role1 = Role.new(person: @person, role_object:  role_object, type: 'SourceAuthor')
        expect(role1.valid?).to be_truthy
        role1.save
        role2 = Role.new(person: @person, role_object:  role_object, type: 'SourceAuthor')
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
    end 
  end

  context "associations" do
    context "belongs_to" do
      specify "person" do
        expect(role).to respond_to(:person)
      end
    end
  end

end
