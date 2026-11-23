# A Layout is a Composition instance, the arrangement of specific things,
# e.g. these labels on this page. Layouts are never community.
#
class Layout < Composition

  # Layouts reference instance data, enforced here so that subclasses can
  # not opt in via .community_permitted?
  validates :is_community, absence: true

end
