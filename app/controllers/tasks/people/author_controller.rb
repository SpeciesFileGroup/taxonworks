class Tasks::People::AuthorController < ApplicationController
  include TaskControllerConfiguration

  def list

  end

  def source_list_for_author
    @person  = Person.find(params[:id])
    @sources = Source.where('false')
  end
end
