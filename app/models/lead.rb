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

  has_closure_tree order: 'position', numeric_order: true, dont_order_roots: true , dependent: nil

  belongs_to :parent, class_name: 'Lead'

  belongs_to :otu, inverse_of: :leads
  has_one :taxon_name, through: :otu
  belongs_to :redirect, class_name: 'Lead'

  has_many :redirecters, class_name: 'Lead', foreign_key: :redirect_id, inverse_of: :redirect, dependent: :nullify

  before_save :check_is_public

  validate :root_has_title
  validate :link_out_has_protocol
  validate :redirect_node_is_leaf_node
  validate :node_parent_doesnt_have_redirect
  validate :root_has_no_redirect
  validate :redirect_isnt_ancestor_or_self

  def future
    redirect_id.blank? ? all_children : redirect.all_children
  end

  def go_id
    (redirect_id.presence || id)
  end

  def dupe
    return false if parent_id
    begin
      Lead.transaction do
        dupe_in_transaction(self, parent_id)
      end
    rescue ActiveRecord::RecordInvalid
      return false
    end
    true
  end

  # left/right/middle
  def node_position
    o = self_and_siblings.order(:position).pluck(:id)
    return :root if o.size == 1
    return :left if o.index(id) == 0
    return :right if o.last == id
    return :middle
  end

  def self.draw(lead, indent = 0)
    puts Rainbow( (' ' * indent) + lead.text ).purple + ' ' + Rainbow( lead.node_position.to_s ).red + ' ' + Rainbow( lead.position ).blue + ' [.parent: ' + Rainbow(lead.parent&.text || 'none').gold + ']'
    lead.children.reload.order(:position).each do |c|
      draw(c, indent + 1)
    end
    nil
  end

  def insert_couplet
    c,d = nil, nil

    p = node_position

    t1 = 'Inserted node'
    t2 = 'Child nodes are attached to this node'

    if children.any?
      o = children.to_a

      left_text = (p == :left || p == :root) ? t2 : t1
      right_text = (p == :right) ? t2 : t1
      # !! middle handling

      c = Lead.create!(text: left_text, parent: self)
      d = Lead.create!(text: right_text, parent: self)

      o.each do |i|
        if p == :left || p == :root
          i.update!(parent: c)
        else
          i.update!(parent: d)
        end

      end
    else
      c = Lead.create!(text: t1, parent: self)
      d = Lead.create!(text: t1, parent: self)
    end

    [c.id, d.id]
  end

  # Destroy the children of this Lead, re-appending the grand-children to self
  #  !! Do not destroy couplet if children on > 1 side exist
  def destroy_couplet
    k = children.order(:position).reload.to_a
    return true if k.empty?

    # TODO: handle multiple facets
    # not first/last because that gives us a==b scenarious
    a = k[0]
    b = k[1]

    c = a.children.to_a
    d = b&.children&.to_a || []

    if (c.size == 0) or (d.size == 0) # At least one side, but not two have children
      if (c.size > 0) || (d.size > 0) # One side has children

        has_kids = c.size > 0 ? a : b
        no_kids = c.size == 0 ? a : b

        i = has_kids.children

        # !! Use append_sibling, which is numeric_order-aware, to reparent
        # the children of has_kids to self.
        last_sibling = children[-1]
        i.each do |z|
          last_sibling.append_sibling z
          last_sibling = z
        end

        has_kids.destroy!
        no_kids.destroy!
      else # Neither side has children
        Lead.transaction do
          a.destroy!
          b&.destroy!
        end
      end
      true
    else #
      false
    end
  end

  def transaction_nuke(lead = self)
    Lead.transaction do
      nuke(lead)
    end
  end

  def nuke(lead = self)
    lead.children.each do |c|
      c.nuke(c)
    end
    destroy!
  end

  # TODO: Probably a helper method
  def all_children(node = self, result = [], depth = 0)
    for c in [node.children.second, node.children.first].compact # intentionally reversed
      c.all_children(c, result, depth + 1)
      a = {}
      a[:depth] = depth
      a[:cpl] = c
      a[:cplLabel] = node.origin_label
      result.push(a)
    end
    result
  end

  # TODO: Probably a helper method
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

  def link_out_has_protocol
    errors.add(:link, 'must include https:// or http://') if !link_out.nil? && !(link_out.start_with?('https://') || link_out.start_with?('http://'))
  end

  def redirect_node_is_leaf_node
    errors.add(:redirect, "nodes can't have children") if redirect_id && children.size > 0
  end

  def node_parent_doesnt_have_redirect
    errors.add(:parent, "can't be a redirect node") if parent && parent.redirect_id
  end

  def redirect_isnt_ancestor_or_self
    errors.add(:redirect, "can't be an ancestor") if redirect_id && (redirect_id == id || ancestor_ids.include?(redirect_id))
  end

  def root_has_no_redirect
    errors.add(:root, "nodes can't have a redirect") if redirect_id && parent_id.nil?
  end

  def dupe_in_transaction(node, parentId)
    a = node.dup
    a.parent_id = parentId
    a.text = '(COPY OF) ' + a.text if parentId == nil
    a.save!

    for c in node.children
      dupe_in_transaction(c, a.id)
    end
  end

  def check_is_public
    if parent_id.nil?
      self.is_public ||= false
    else
      self.is_public = nil
    end
  end

end
