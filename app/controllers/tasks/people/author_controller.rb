class AuthorController < ApplicationController
  include TaskControllerConfiguration
  def index
    @author_index_list = Person.all
  end
end
