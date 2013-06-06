require 'spec_helper'

describe SpecimenDetermination do

  let(:specimen_determination) { SpecimenDetermination.new }

  # foreign key relationships
  context "reflections / foreign keys" do
    context "belongs to" do
      specify "Specimen" do
        expect(specimen_determination).to respond_to(:specimen)
      end

      specify "Otu" do
        expect(specimen_determination).to respond_to(:otu)
      end
    end
  end

  context "validation" do
    context "requires" do
      before do
        specimen_determination.save
      end

      # Note "otu" not "otu_id"
      specify 'otu_id' do 
        expect(specimen_determination.errors.include?(:otu)).to be_true
      end

      specify 'specimen_id' do 
        expect(specimen_determination.errors.include?(:specimen)).to be_true
      end
    end

    context "other" do
      specify "only one of a specimens determinations can be current" do
        pending
      end
    end

  end

  context "requirements" do
    it "it has, by default, an ordering based on date"
    it "the default ordering can be over-ridden by sort order"
    it "it can be defined as the current determination"
    it "can store a date the determination was made"
    it "can have a source"
  end

  context "concerns" do
    # pending 
    # it_behaves_like "has confidence"
  end

end
