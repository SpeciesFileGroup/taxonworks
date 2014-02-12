class TaxonNamesController < ApplicationController

  def demo
    @taxon_name = TaxonName.first


  end

  def marilyn
    @users=User.all
  end

end
