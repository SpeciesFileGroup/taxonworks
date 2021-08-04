require 'taxon_names_helper.rb'
class Api::V1::CiteController < ApiController 


  def count_valid_species
    @base = Queries::TaxonName::Filter.new(
      name: params.require(:taxon_name),
      exact: 'true', 
      validity: 'true'
    ).all
  end

end
