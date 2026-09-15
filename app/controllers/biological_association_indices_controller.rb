class BiologicalAssociationIndicesController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  # GET /biological_association_indices/download
  def download
    send_data Export::CSV.generate_csv(
      BiologicalAssociationIndex.where(project_id: sessions_current_project_id)),
      type: 'text', filename: "biological_association_indices_#{DateTime.now}.tsv"
  end

end
