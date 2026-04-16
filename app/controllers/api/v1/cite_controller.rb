class Api::V1::CiteController < ApiController

  def count_valid_species
    @base = Queries::TaxonName::Filter.new(
      name: params.require(:taxon_name),
      exact: true,
      validify: true
    ).all
  end

end
