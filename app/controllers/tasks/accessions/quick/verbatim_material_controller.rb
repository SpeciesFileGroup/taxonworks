class Tasks::Accessions::Quick::VerbatimMaterialController < ApplicationController


  def new
    @repositories = Repository.order(:name).all
    @namespaces = Namespace.order(:name).all
  end

  def create
    foo = 1
  end

  def identifier

  end

end