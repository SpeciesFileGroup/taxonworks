class Tasks::Sources::SourceCitationTotalsController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @sources = Queries::Source::Filter.new(params).all.order(:cached)
  end

end
