class Tasks::People::AuthorController < ApplicationController
  include TaskControllerConfiguration

  def index
  end

  def source_list_for_author
    @person  = Person.find(params[:id])
    @sources = Source.where(id: @person.roles.where(type: 'SourceAuthor').map(&:role_object_id))
  end

end
