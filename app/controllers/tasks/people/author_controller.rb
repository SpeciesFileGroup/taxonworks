class Tasks::People::AuthorController < ApplicationController
  include TaskControllerConfiguration
  def index
    @author_index_list = Person.with_role('SourceAuthor').ordered_by_last_name
  end
end
