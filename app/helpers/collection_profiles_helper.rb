module CollectionProfilesHelper
  def collection_profile_tag(collection_profile)
    return nil if collection_profile.blank?
    [container_tag(collection_profile.container), otu_tag(collection_profile.otu) ].compact.join(": ").html_safe
  end
end
