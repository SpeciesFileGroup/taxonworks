class Tasks::Accessions::Report::DwcaController < ApplicationController
  include TaskControllerConfiguration

  def index 
    @collection_objects = CollectionObject.with_project_id($project_id).order(:id).page(params[:page]) #.per(10) 
  end

end
