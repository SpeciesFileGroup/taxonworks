module CollectionObjectsHelper
  
  def collection_object_tag(collection_object)
    # TODO: generate catalog number / biological attributes reference?
    collection_object.to_param

  end

end
