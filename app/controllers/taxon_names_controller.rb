class TaxonNamesController < ApplicationController

  def demo
    @taxon_name = TaxonName.first
  end

end
