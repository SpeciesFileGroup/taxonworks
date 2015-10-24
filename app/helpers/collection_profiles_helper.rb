module CollectionProfilesHelper

  def collection_profile_tag(collection_profile)
    return nil if collection_profile.blank?
    [container_tag(collection_profile.container), otu_tag(collection_profile.otu)].compact.join(": ").html_safe
  end

  def collection_profile_link(collection_profile)
    return nil if collection_profile.nil?
    link_to(collection_profile_tag(collection_profile).html_safe, collection_profile)
  end

  def collection_profiles_search_form
    render('/collection_profiles/quick_search_form')
  end

# @todo Not sure if this is needed. If it is, there is no collection_profiles.name...
# def collection_profiles_link_list_tag(collection_profiles)
#   collection_profiles.collect { |c| link_to(c.name, c) }.join(",")
# end
end
