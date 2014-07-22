require 'rails_helper'

describe Api::V1::TaxonNamesController do

  describe "Taxon names API" do

    describe "all method" do
      it "returns http success" do
      #TODO: Check why "get" is requiring explicit format specifier whilst accessing the controller with curl doesn't. Also, is it better this way?
        get 'all', format: :json
        expect(response).to be_success
      end
      
      it "assigns TaxonName.all to @names" do
        get 'all', format: :json
        expect(assigns(:names)).to eq(TaxonName.all)
      end 

      it "renders template all" do
        get 'all', format: :json
        expect(response).to render_template "api/v1/taxon_names/all"
      end
      
    end
  end

end
