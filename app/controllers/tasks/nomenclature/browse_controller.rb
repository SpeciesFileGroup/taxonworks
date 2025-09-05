class Tasks::Nomenclature::BrowseController < ApplicationController
  include TaskControllerConfiguration

  def index
    id = params[:taxon_name_id] || params[:combination_id]

    @taxon_name = TaxonName.where(project_id: sessions_current_project_id).find(id) if id.present?
    @taxon_name ||= Project.find(sessions_current_project_id).root_taxon_name
    redirect_to :new_taxon_name_task, notice: 'No names to browse yet.' and return if @taxon_name.nil?

    @data = ::Catalog::Nomenclature::Entry.new(@taxon_name)
  end

end
