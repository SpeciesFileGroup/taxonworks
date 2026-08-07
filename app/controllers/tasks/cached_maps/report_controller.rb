class Tasks::CachedMaps::ReportController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def items_by_otu
    @otus = ::Queries::Otu::Filter.new(params).all.limit(10).page(params[:page]).per(params[:per])
    @cached_map_items = CachedMapItem.where(otu: @otus).distinct.limit(500)
  end

end
