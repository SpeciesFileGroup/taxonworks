module CollectionObjectsHelper

  # Return [String, nil]
  #   a descriptor including the identifier and determination
  def collection_object_tag(collection_object)
    return nil if collection_object.nil?
    str = [
      identifier_tag(collection_object.identifiers.first),
      taxon_determination_tag(collection_object.taxon_determinations.first)
    ].compact.join(" ").html_safe
    str = collection_object.type if str == ""
    str
  end

  def collection_object_link(collection_object)
    return nil if collection_object.nil?
    link_to(collection_object_tag(collection_object).html_safe, collection_object.metamorphosize)
  end

  def collection_objects_search_form
    render('/collection_objects/quick_search_form')
  end

  def verify_accessions_task_link(collection_object)
    priority = [collection_object.container, collection_object.identifiers.first, collection_object ].compact.first
    link_to('Verify', verify_accessions_task_path(by: priority.metamorphosize.class.name.tableize.singularize.to_sym, id: priority.to_param))
  end

end
