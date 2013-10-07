require 'spec_helper'

describe Source do

  let(:source) { Source.new }




  context "concerns" do
    it_behaves_like "identifiable"
    it_behaves_like "has_roles"
  end



end


