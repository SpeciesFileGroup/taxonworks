class Tasks::Gis::OtuDistributionDataController < ApplicationController
  include TaskControllerConfiguration

  # show_for_otu
  def show
    id = params[:id]
    if id.blank?
      @otu = Otu.first
    else
      @otu = Otu.find(id)
    end
    @taxon_name   = @otu.taxon_name
    @distribution = Distribution.new(otus: Otu.where(id: @otu.id).page(params[:page]))
    @type_tag     = 'Otu'
    render('show')
  end

  def show_for_taxon_name
    @taxon_name   = TaxonName.find(params[:id])
    @distribution = Distribution.new(otus: Otu.for_taxon_name(@taxon_name).page(params[:page]))
    @type_tag     = 'Taxon name'
    render('show')
  end


  # def show2
  #   id = params[:id]
  #   if id.blank?
  #     @otu = Otu.first
  #   else
  #     @otu = Otu.find(id)
  #   end
  #   @distribution = Distribution.new(otus: [@otu])
  # end
end
