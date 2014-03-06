class Api::V1::TaxonNamesController < ApplicationController
  respond_to :json
  
  def all
    @names = TaxonName.all
  end
end
