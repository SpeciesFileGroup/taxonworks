class Tasks::TaxonNames::AuthorSummaryController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @taxon_names_query = ::Queries::TaxonName::Filter.new(params[:taxon_name_query])
    @taxon_names = @taxon_names_query.all.left_joins(:taxon_name_authors)
    @author_data = ApplicationController.helpers.summarize_authors_by_year(@taxon_names)
    @coauthorship_data = ApplicationController.helpers.author_coauthorship_data(@taxon_names)
  end

end
