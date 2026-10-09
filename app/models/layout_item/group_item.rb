# A set of LayoutItems in a Layout, e.g. images selected together, so that
# they can be labelled and moved as one. Members are its children (their
# parent_id). A GroupItem references no object.
#
# Intent: groups are translation only.
# * x, y: an offset applied to all members (members' x, y are relative to
#   it, see CompositionItem's Coordinate system). nil is 0, so a group
#   created at nil/0 leaves its members exactly where they were. Moving a
#   set is one update of the group's x, y.
# * text: optional label.
#
# Limitations (deliberate, may be revisited):
# * No zoom, rotation_z, z, width, height, crop, opacity or visibility on a
#   group. Rotating or scaling a set is done on the members, by the client.
#   Members stack by their own z, interleaved with everything else.
# * No stored bounds: a group's extent is derived from its members, by the
#   client (e.g. for a selection outline), so it can never go stale.
# * An item belongs to at most one group (parent_id). For overlapping,
#   many-to-many sets use Tags on the depicted objects.
#
class LayoutItem::GroupItem < LayoutItem

  validates_absence_of :z, :zoom, :rotation_z, :width, :height,
    :svg_view_box, :svg_clip, :opacity, :is_visible,
    message: 'is not supported on a group'

  # Removes the group, keeping its members where they appear: each member
  # moves to the group's parent, with the group's offset added to its x, y.
  # @return [Array of LayoutItem]
  #   the former members
  def ungroup!
    members = children.to_a
    transaction do
      members.each do |m|
        m.update!(
          parent_id:,
          x: (m.x || 0) + (x || 0),
          y: (m.y || 0) + (y || 0)
        )
      end
      destroy!
    end
    members
  end

end
