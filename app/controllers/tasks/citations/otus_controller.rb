class Tasks::Citations::OtusController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @citation = Citation.new(source: Source.new, citation_object: Otu.new )
  end

end
