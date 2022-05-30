class Tasks::CollectionObjects::ClassificationSummaryController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
  end

  def report
    @ancestor = TaxonName.where(project_id: sessions_current_project_id).where(id: params[:ancestor_id]).first
    @ancestor ||= sessions_current_project.root_taxon_name
    @data = ::Queries::TaxonName::Filter.new(
      project_id: sessions_current_project_id,
      taxon_name_id: @ancestor.id,
      descendants: true,
      rank: params[:rank]).all.order(:cached)
    @rank = params[:rank]
  end

end
