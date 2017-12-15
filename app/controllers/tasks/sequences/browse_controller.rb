class Tasks::Sequences::BrowseController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
  end

  # POST
  def sequences
    gene_id = params[:gene_id]
    gene = Descriptor.find_by(id: gene_id)
    sequences = []
    sequences = gene.sequences if gene
    
    render :json => sequences
  end
end