class Tasks::TaxonNames::GenderController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @taxon_names_query = ::Queries::TaxonName::Filter.new(params[:taxon_name_query])
    @taxon_names = @taxon_names_query.all.where(type: 'Protonym').eager_load(:valid_taxon_name).order(:name)
  end

end
