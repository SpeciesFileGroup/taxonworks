# Leads models dichotomous keys; each row represents a single couplet option in a key.
#
# @!attribute parent_id
#   @return [integer]
#   Id of the lead immediately prior to this one in the key
#
# @!attribute otu_id
#   @return [integer]
#   Otu determined at this stage of the key, if any
#
# @!attribute text
#   @return [text]
#   Text for this option of a couplet in the key; title of the key on the root
#   node
#
# @!attribute origin_label
#   @return [string]
#   If the couplet was given a # in print, that number
#
# @!attribute description
#   @return [text]
#   Only used on the root node, to describe the overall key
#
# @!attribute redirect_id
#   @return [integer]
#   Id of the lead to redirect to if this option of the couplet is chosen
#
# @!attribute link_out
#   @return [text]
#   Provides a URL to display on this node
#
# @!attribute link_out_text
#   @return [string]
#   Text to display for the link_out URL
#
# @!attribute position
#   @return [integer]
#   A sort order used by has_closure_tree
#
# @!attribute is_public
#   @return [boolean]
#   True if the key is viewable without being logged in
#
class Lead < ApplicationRecord
  include Housekeeping
  include Shared::Tags
  include Shared::Citations
  include Shared::IsData

  belongs_to :parent, class_name: 'Lead'
  # has_closure_tree uses 'children', so we use 'kids' instead.
  has_many :kids, class_name: 'Lead', foreign_key: :parent_id, inverse_of: :parent, dependent: :destroy
  belongs_to :otu, inverse_of: :leads
  belongs_to :redirect, class_name: 'Lead'

  has_closure_tree order: 'position', numeric_order: true, dont_order_roots: true

  def display_name
    id.to_s + ': ' + text.slice(0..40) + (text.size > 40 ? '...' : '')
  end

  def future
    self.redirect_id.blank? ? self.all_children : self.redirect.all_children
  end

  def go_id
    (self.redirect_id.presence || self.id)
  end

  def dupe(node = self, id = nil)
    a = node.dup
    a.parent_id = parentId
    a.description = (a.description ? (a.description + ' (COPY)') : '(COPY)') if parentId == nil
    a.save!

    for c in node.children
      dupe(c, a.id)
    end

    true
  end

  def insert_couplet
    if cs = self.children
      a = cs[0]
      b = cs[1]
    end

    c = self.children.create!(text: 'Child nodes, if present, are attached to this node.')
    d = self.children.create!(text: 'Inserted node')

    if not a == nil
      a.update!(parent_id: c.id)
      b.update!(parent_id: c.id)
    end

    [c.id, d.id]
  end

  def destroy_couplet # if refactored do with care, parent/child relationships cause some unexpected behaviour
    return false if self.children.size == 0
    a = self.children[0]
    b = self.children[1]

    if (a.children.size == 0) or (b.children.size == 0)
      for c in [a, b]
        for d in c.children
          d.parent = self # update(parent_id: self.id)
          d.save!
        end
      end
      Lead.find(a.id).destroy! # NOTE WE CANNOT just do a.destroy, as this invokes bizarre cascading nastiness!!
      Lead.find(b.id).destroy!
      true
    else
      false
    end
  end

  def all_children(node = self, result = [], depth = 0)
    for c in [node.children.second, node.children.first].compact # intentionally reversed
      c.all_children(c, result, depth + 1)
      a = {}
      a[:depth] = depth
      a[:cpl] = c
      result.push(a)
    end
    result
  end

  def all_children_standard_key(node = self, result = [], depth = 0) # couplets before depth
    ch = node.children
    for c in ch
      a = {}
      a[:depth] = depth
      a[:cpl] = c
      result.push(a)
    end

    for c in ch
      c.all_children_standard_key(c, result, depth + 1)
    end
    result
  end

end
