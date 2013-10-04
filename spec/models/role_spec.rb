require 'spec_helper'

describe Role do
  let(:role) { Role.new }

  context "validation" do
    before do
      role.valid?
    end
    context "required fields" do
      specify "person_id" do
        expect(role.errors.include?(:person_id)).to be_true
      end
     specify "type" do
        expect(role.errors.include?(:type)).to be_true
      end
      specify "role_object_id" do
        expect(role.errors.include?(:role_object_id)).to be_true
      end
      specify "role_object_type" do
        expect(role.errors.include?(:role_object_type)).to be_true
        end
      specify "position" do
        expect(role.errors.include?(:position)).to be_true
        end
    end
  end

  context "reflections / foreign keys" do
    context "belongs_to" do
      specify "person" do
        expect(role).to respond_to(:person)
      end
     end
  end

end
