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


end
