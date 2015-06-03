module CollectionObjectObservationsHelper

  def collection_object_observation_tag(collection_object_observation)
    return nil if collection_object_observation.nil?
    collection_object_observation.data
  end

  def collection_object_observations_search_form
    render('/collection_object_observations/quick_search_form')
  end


end
