require 'spec_helper'

describe Person do
  let(:person) { Person.new }

  context "validation" do
    before do
      person.valid?
    end
    specify "last_name is required" do
      expect(person.errors.keys).to include(:last_name)
    end
  end
=begin
    specify "type is required" do
      expect(person.errors.keys).to include(:type)
    end

=end
  context "on save" do
    before do
      person.last_name = "Smith"
      person.save
    end
    specify "type is set to Anonymous when not provided" do
      expect(person.type).to eq("Anonymous")
    end
  end

  context "reflections / foreign keys" do
    context "has_many" do
      specify "roles" do
        expect(person).to respond_to(:roles)
      end
    end
  end



end

