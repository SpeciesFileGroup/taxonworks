require 'spec_helper'

describe Api::V1::TaxonNamesController do

  describe "Taxon names API" do

    describe "all method" do
      it "returns http success" do
      #TODO: Check why "get" is requiring explicit format specifier whilst accessing the controller with curl doesn't. Also, is it better this way?
        get 'all', format: :json
        expect(response).to be_success
      end
    end
  end

end
