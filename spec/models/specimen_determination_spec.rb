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
  end

end
