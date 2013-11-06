require 'spec_helper'

describe Citation do
  let(:citation) {Citation.new}

  context 'associations' do

    context 'belongs_to' do
      specify 'citation_object' do
        expect(citation).to respond_to(:citation_object)
      end

      specify 'source' do
        expect(citation).to respond_to(:source)
      end
    end
  end

  context 'validations' do
    # check for all required fields.
  end

  context 'concerns' do
    specify 'isolate and create concern citable (see identifiable concern)' 
  end

  context 'Beth' do
    context 'create a citation' do
      # create a citation linking a specimen (collection_object?) to a source
      # create a citation linking a nomenclatural act (what object represents this?) to a source.
    end

  end

end
