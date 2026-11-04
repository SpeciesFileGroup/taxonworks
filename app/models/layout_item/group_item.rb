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
# * Groups are the only parents allowed in a Layout (see LayoutItem), so a
#   renderer only ever sums offsets: it can paint all leaf items in one
#   layer sorted by z, and treat groups as logical (offset + membership).
# * An item belongs to at most one group (parent_id). For overlapping,
#   many-to-many sets use Tags on the depicted objects.
#
# Destroying a group ungroups: its members are kept where they appear (see
# #release_members). To remove a group and its members, destroy the
# members too.
#
class LayoutItem::GroupItem < LayoutItem

  validates_absence_of :z, :zoom, :rotation_z, :width, :height,
    :svg_view_box, :svg_clip, :opacity, :is_visible,
    message: 'is not supported on a group'

  # Before the children cascade (CompositionItem has_many :children,
  # dependent: :destroy), so that it finds none. Skipped when destroyed by a
  # cascade (e.g. its Composition's), where the members go too.
  before_destroy :release_members, prepend: true,
    if: -> { destroyed_by_association.nil? }

  protected

  # Keeps the members where they appear: each moves to the group's parent,
  # with the group's offset added to its x, y. Members are appended to the
  # parent's list in their order.
  def release_members
    children.order(:position).each do |m|
      m.update!(
        parent_id:,
        x: (m.x || 0) + (x || 0),
        y: (m.y || 0) + (y || 0)
      )
    end
    # The cascade must not reuse the loaded (now released) members.
    children.reset
  end

end
