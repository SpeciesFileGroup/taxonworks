class Tasks::TaxonNames::StatsController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @taxon_names = ::Queries::TaxonName::Filter.new(params).all
  end

end
