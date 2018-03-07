module CollectionProfilesHelper

  def collection_profile_tag(collection_profile)
    return nil if collection_profile.blank?
    [container_tag(collection_profile.container), otu_tag(collection_profile.otu)].compact.join(': ').html_safe
  end

  def collection_profile_link(collection_profile)
    return nil if collection_profile.nil?
    link_to(collection_profile_tag(collection_profile).html_safe, collection_profile)
  end

# def collection_profiles_search_form
#   render('/collection_profiles/quick_search_form')
# end

  def collection_profile_attribute_status_tag(collection_profile, attribute)
    v = collection_profile.send(attribute)
    v ||= COLLECTION_PROFILE_INDICES[:Favret][collection_profile.collection_type.to_sym][attribute].keys.first
    "#{v} - " + COLLECTION_PROFILE_INDICES[:Favret][collection_profile.collection_type.to_sym][attribute][v]
  end

  def collection_profile_select_options(collection_type, attribute, selected)
    options_for_select(
      COLLECTION_PROFILE_INDICES[:Favret][collection_type.to_sym][attribute].collect{|i,t| ["#{i} - #{t}", i]},
      selected: selected
    )
  end

  def collection_profile_select(collection_profile, attribute)
    select_tag("collection_profile[#{attribute}]", collection_profile_select_options(collection_profile.collection_type, attribute, collection_profile.send(attribute))  )
  end

end
