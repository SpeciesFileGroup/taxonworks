class Tasks::Sequences::BrowseController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
  end

  # POST
  def sequences
    sequences = []
    gene_id = params[:gene_id]
    gene = Descriptor.find_by(id: gene_id)

    if gene
      sequences = gene.sequences
      puts gene
    end

    render :json => sequences
  end
end