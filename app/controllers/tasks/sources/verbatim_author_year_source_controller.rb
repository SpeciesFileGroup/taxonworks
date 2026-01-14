class Tasks::Sources::VerbatimAuthorYearSourceController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    # Query for k verbatim_author and year_of_publication combinations
    @author_year_data = TaxonName
      .where(project_id: sessions_current_project_id)
      .where.not(verbatim_author: nil)
      .where.not(year_of_publication: nil)
      .where.missing(:citations)
      .group(:verbatim_author, :year_of_publication)
      .select('verbatim_author, year_of_publication, COUNT(*) as record_count')
      .order('year_of_publication DESC, record_count DESC')

    # Calculate max count for heat map normalization
    @max_count = @author_year_data.map(&:record_count).max&.to_f || 1.0
  end

end
