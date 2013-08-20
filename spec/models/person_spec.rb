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
end

=begin
describe Otu do
  let(:otu) { Otu.new }

  # foreign key relationships
  context "reflections / foreign keys" do

    context "has many" do
      specify "specimen determinations" do
        expect(otu).to respond_to(:specimen_determinations)
      end

      specify "contents" do
        expect(otu).to respond_to(:contents)
      end

      specify "otu contents" do
        expect(otu).to respond_to(:otu_contents)
      end

      specify "topics" do
        expect(otu).to respond_to(:topics)
      end

    end

  end

  context "concerns" do
    it_behaves_like "identifiable"
  end


end
=end
