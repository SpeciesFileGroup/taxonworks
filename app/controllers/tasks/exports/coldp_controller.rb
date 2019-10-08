class Tasks::Exports::ColdpController < ApplicationController
  include TaskControllerConfiguration

  def index
  end

  def download
    params.require(:otu_id)
    @otu = Otu.where(project_id: sessions_current_project_id).find(params[:otu_id])

    filename = ::Export::Coldp.export(params[:otu_id])

    send_data File.read(filename), 
      type: 'zip',
      filename: "coldp_otu_id_#{params[:otu_id]}_#{DateTime.now}.zip"
  end
end
