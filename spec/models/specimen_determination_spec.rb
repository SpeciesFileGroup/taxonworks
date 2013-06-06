require 'spec_helper'

describe SpecimenDetermination do

  let(:sd) { SpecimenDetermination.new }
  # foreign key relationships
  specify "it belongs to a Specimen" do
    expect(sd).to respond_to(:specimen)
  end

  # foreign key relationships
  specify "it belongs to an Otu" do
    expect(sd).to respond_to(:otu)
  end



end
