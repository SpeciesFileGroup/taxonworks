class Tasks::TaxonNames::TableController < ApplicationController
  include TaskControllerConfiguration

  # GET/POST
  def index
    @taxon_names_query = ::Queries::TaxonName::Filter.new(params[:taxon_names_query])
    @taxon_names = @taxon_names_query.all
  end
end

