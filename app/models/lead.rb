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
  has_one :taxon_name, through: :otu
  belongs_to :redirect, class_name: 'Lead'
  has_many :redirecters, class_name: 'Lead', foreign_key: :redirect_id, inverse_of: :redirect, dependent: :restrict_with_error

  # This needs to go before has_closure_tree.
  before_destroy :set_root_updated_on_destroy, unless: -> { parent_id.nil? }

  acts_as_list scope: [:parent_id, :project_id]
  has_closure_tree order: 'position'

  before_save :check_is_public
  # This needs to go after has_closure_tree.
  after_save :set_root_updated, unless: -> { parent_id.nil? }

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

  def insert_couplet

    if cs = children
      a = cs[0]
      b = cs[1]
    end

    children_present = cs && !a.nil? && !b.nil?
    current_node_is_left_child = !parent_id || (parent.children[0].id == id)

    begin
      texts = {
        parented: children_present ?
          'Child nodes are attached to this node' : 'Inserted node',
        unparented: 'Inserted node'
      }
      left_text =
        current_node_is_left_child ? texts[:parented] : texts[:unparented]
      right_text =
        current_node_is_left_child ? texts[:unparented] : texts[:parented]

      c, d = Lead.transaction do
        [
          children.create!(text: left_text),
          children.create!(text: right_text)
        ]
      end
    rescue ActiveRecord::RecordInvalid
      return []
    end

    if children_present
      new_parent = current_node_is_left_child ? c : d
      # !! Test thoroughly here! Many things you might expect to work may give
      # you the wrong order for a and b and/or c and d.
      a.update!(parent: new_parent)
      b.update!(parent: new_parent)
      a.reload
      b.reload
      c.reload
      d.reload
      a.set_list_position(1)
      b.set_list_position(2)
      c.set_list_position(1)
      d.set_list_position(2)
    end

    [c.id, d.id]
  end

  def destroy_couplet
    return true if children.size == 0
    a = children[0]
    b = children[1]

    if (a.children.size == 0) or (b.children.size == 0)
      if (a.children.size > 0) || (b.children.size > 0)
        has_kids = a.children.size > 0 ? a : b
        no_kids = a.children.size == 0 ? a : b

        begin
          Lead.transaction do
            # !! Test thoroughly here! Many things you might expect to work may
            # give you the wrong order for the reparented children.
            has_kids.children[0].update!(parent: self)
            has_kids.children[1].update!(parent: self)

            has_kids.destroy!
            no_kids.destroy!
          end
        rescue ActiveRecord::RecordNotDestroyed
          return false
        end
      else
        begin
          Lead.transaction do
            a.destroy!
            b.destroy!
          end
        rescue ActiveRecord::RecordNotDestroyed
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
      a[:cplLabel] = node.origin_label
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

  def set_root_updated
    return if not saved_changes?

    self.root.update_column :updated_at, self.updated_at
    if self.root.updated_by_id != self.updated_by_id
      self.root.update_column :updated_by_id, self.updated_by_id
    end
  end

  def set_root_updated_on_destroy
    self.root.update_column :updated_at, Time.now.utc
    if self.root.updated_by_id != Current.user_id
      self.root.update_column :updated_by_id, Current.user_id
    end
  end
end
