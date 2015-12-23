class Tasks::People::AuthorController < ApplicationController
  include TaskControllerConfiguration

  def list

  end

  def source_list_for_author
    @person  = Person.find(params[:id])
    # todo: MB - how do you find the sources for an author?
    @sources = Source.where('false')
  end
end
