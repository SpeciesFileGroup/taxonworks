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
  include Shared::Citations
  include Shared::Depictions
  include Shared::Tags
  include Shared::IsData

  belongs_to :parent, class_name: 'Lead'
  # has_closure_tree uses 'children', so we use 'kids' here instead.
  has_many :kids, class_name: 'Lead', foreign_key: :parent_id, inverse_of: :parent, dependent: :destroy
  belongs_to :otu, inverse_of: :leads
  belongs_to :redirect, class_name: 'Lead'

  has_closure_tree order: 'position', numeric_order: true, dont_order_roots: true

  validate :root_has_title
  validate :link_out_has_no_protocol

  def future
    redirect_id.blank? ? all_children : redirect.all_children
  end

  def go_id
    (redirect_id.presence || id)
  end

  def dupe(node = self, parentId = nil)
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
    if cs = children
      a = cs[0]
      b = cs[1]
    end

    begin
      c, d = Lead.transaction do
        [
          children.create!(text: 'Child nodes, if present, are attached to this node.'),
          children.create!(text: 'Inserted node')
        ]
      end
    rescue ActiveRecord::RecordInvalid
      return []
    end

    if !a.nil?
      # !! Test thoroughly here! Many things you might expect to work may give
      # you the wrong order for a and b.
      c.add_child a
      a.append_sibling b
    end

    [c.id, d.id]
  end

  def destroy_couplet
    return true if children.size == 0
    a = children[0]
    b = children[1]

    if (a.children.size == 0) or (b.children.size == 0)
      if (a.children.size > 0) || (b.children.size > 0)
        # !! Test thoroughly here! Many things you might expect to work may
        # give you the wrong order for the reparented children.
        has_kids = a.children.size > 0 ? a : b
        no_kids = a.children.size == 0 ? a : b
        # TODO: find a way to make this work reliably with fewer queries.
        first_child = Lead.find has_kids.children[0].id
        second_child = Lead.find has_kids.children[1].id
        begin
          Lead.transaction do
            add_child first_child
            first_child.append_sibling second_child
            Lead.find(has_kids.id).destroy! # NOTE WE CANNOT just do has_kids.destroy, as this invokes bizarre cascading nastiness!!
            no_kids.destroy!
          end
        rescue ActiveRecord::RecordInvalid
          return false
        end
      else
        begin
          Lead.transaction do
            a.destroy!
            b.destroy!
          end
        rescue ActiveRecord::RecordInvalid
          return false
        end
      end
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

  protected

  def root_has_title
    errors.add(:root_node, 'must have a title') if parent_id.nil? and text.nil?
  end

  def link_out_has_no_protocol
    errors.add(:link, "shouldn't include http") if link_out&.start_with? 'http' or link_out&.include? '://'
  end

end
