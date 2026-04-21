class Tasks::Sources::VerbatimAuthorYearSourceController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    # Use Filter to scope results based on params
    @taxon_name_filter = ::Queries::TaxonName::Filter.new(params)

    # Query for unique verbatim_author and year_of_publication combinations
    # applying the filter scope first
    @author_year_data = @taxon_name_filter.all
      .where.not(verbatim_author: nil)
      .where.not(year_of_publication: nil)
      .where.missing(:citations)
      .group(:verbatim_author, :year_of_publication)
      .select('verbatim_author, year_of_publication, COUNT(*) as record_count')
      .order('year_of_publication DESC, record_count DESC')

    # Calculate max count for heat map normalization
    @max_count = @author_year_data.map(&:record_count).max&.to_f || 1.0

    respond_to do |format|
      format.html # Render the Vue.js mounting point
      format.json { render json: author_year_json }
    end
  end

  private

  def author_year_json
    data = @author_year_data.map do |row|
      normalized_value = row.record_count.to_f / @max_count
      heat_color = Utilities::Heatmap.heatmap_color_for(
        normalized_value,
        curve: :citation_count,
        count: row.record_count
      )

      {
        verbatim_author: row.verbatim_author,
        year_of_publication: row.year_of_publication,
        record_count: row.record_count,
        heat_color: heat_color
      }
    end

    {
      data: data,
      max_count: @max_count
    }
  end

end
