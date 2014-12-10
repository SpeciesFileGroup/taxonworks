class Tasks::Accessions::Verify::MaterialController < ApplicationController
  include TaskControllerConfiguration

  before_filter :get_data_to_verify

  def index
  end 

  protected


  # The context (identifier, collection_object or container) is asserted
  # in logic prior to gathering data, so do not fork logic futher here.
  def get_data_to_verify
    @collection_objects = []
    @identifier = nil
    @container = []

    case params[:by].to_sym
    when :container
      @container = Container.find(params[:id])
      @collection_objects = @container.collection_objects
      @identifier = @container.identifiers.first
    when :collection_object
      o = CollectionObject.find(params[:id])
      @collection_objects = [o] 
      @container = o.container
      @identifier = o.identifiers.first if o.identifiers.any?
    when :identifier
      @identifier = Identifier.find(params[:id])
      o = @identifier.identifier_object
      if o.class == Container
       @container = o
      elsif o.class == CollectionObject
        @collection_objects = [o] 
      else
        # raise an error
      end
    end
  end



end
