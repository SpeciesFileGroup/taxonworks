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

  def collection_object_link(collection_object)
    return nil if collection_object.nil?
    link_to(collection_object_tag(collection_object).html_safe, collection_object)
  end

  def collection_objects_search_form
    render('/collection_objects/quick_search_form')
  end

  def verify_accessions_task_link(collection_object)
    options = {}
    priority = [collection_object.container, collection_object.identifiers.first, collection_object ].compact.first
    link_to('Verify', verify_accessions_task_path(by: priority.metamorphosize.class.name.downcase.to_sym, id: priority.to_param))
  end

end
