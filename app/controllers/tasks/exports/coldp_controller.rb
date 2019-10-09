class Tasks::Exports::ColdpController < ApplicationController
  include TaskControllerConfiguration

  def index

  end

  def download
    params.require(:otu_id)
    otu = Otu.where(project_id: sessions_current_project_id).find(params[:otu_id])

    filename = ::Export::Coldp.export(params[:otu_id])
    name = "coldp_otu_id_#{params[:otu_id]}_#{DateTime.now}.zip"

    f = File.read(filename)

    download = Download.create!(
      name: "ColDP Download for #{otu.otu_name} on #{Time.now}.",
      desription: 'A zip file containing CoLDP formatted data.',
      filename: filename, 
      request: request.url,
      expires: 2.days.from_now
    )

    send_data download.file,
      type: 'zip',
      filename: name 
  end
end
