class Api::V1::TaxonNamesController < ApplicationController
  respond_to :json
  
  def all
    respond_with TaxonName.all
  end
end
