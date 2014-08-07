module CollectionObjectsHelper

  def self.collection_object_tag(collection_object)
    return nil if collection_object.nil?
    collection_object.type  # TODO: no 'name' field
  end

  def collection_object_tag(collection_object)
    # TODO: generate catalog number / biological attributes reference?
    # collection_object.to_param
    CollectionObjectsHelper.collection_object_tag(collection_object)
  end

  def collection_objects_link(collection_object)
    return nil if collection_object.nil?
    link_to(collection_object_tag(collection_object).html_safe, collection_object)
  end

end
