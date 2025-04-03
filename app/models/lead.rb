# Leads model multifurcating keys: each lead represents one option in a key.
# The set of options at a given step of the key is referred to as a 'couplet'
# even when there are more than two options.
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
#   Position of this lead amongst the key options at lead's stage of the key;
#   maintained by has_closure_tree
#
# @!attribute is_public
#   @return [boolean]
#   True if the key is viewable without being logged in
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
class Lead < ApplicationRecord
  include Housekeeping
  include Shared::Citations
  include Shared::Depictions
  include Shared::Attributions
  include Shared::Tags
  include Shared::IsData

  has_closure_tree order: 'position', numeric_order: true, dont_order_roots: true, dependent: nil

  belongs_to :parent, class_name: 'Lead'

  belongs_to :otu, inverse_of: :leads
  has_one :taxon_name, through: :otu
  belongs_to :redirect, class_name: 'Lead'

  has_many :redirecters, class_name: 'Lead', foreign_key: :redirect_id, inverse_of: :redirect, dependent: :nullify

  before_save :set_is_public_only_on_root

  validate :root_has_title
  validate :link_out_has_protocol
  validate :redirect_node_is_leaf_node
  validate :node_parent_doesnt_have_redirect
  validate :root_has_no_redirect
  validate :redirect_isnt_ancestor_or_self
  validates_uniqueness_of :text, scope: [:otu_id, :parent_id], unless: -> { otu_id.nil? }

  def future
    redirect_id.blank? ? all_children : redirect.all_children
  end

  # @return [Boolean] true on success, false on error
  def dupe
    if parent_id
      errors.add(:base, 'Can only call dupe on a root lead')
      return false
    end

    begin
      Lead.transaction do
        dupe_in_transaction(self, parent_id)
      end
    rescue ActiveRecord::RecordInvalid => e
      errors.add(:base, "dup failed: #{e}")
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
    lead.children.each do |c|
      draw(c, indent + 1)
    end
  end

  # Return [Boolean] true on success, false on failure
  def insert_key(id)
    if id.nil?
      errors.add(:base, 'Id of key to insert not provided')
      return false
    end
    begin
      Lead.transaction do
        key_to_insert = Lead.find(id)
        if key_to_insert.dupe != true
          raise TaxonWorks::Error, 'dupe failed'
        end

        dup_prefix = '(COPY OF)'
        duped_text = "#{dup_prefix} #{key_to_insert.text}"
        duped_root = Lead.where(text: duped_text).order(:id).last
        if duped_root.nil?
          raise TaxonWorks::Error,
            "failed to find the duped key with text '#{duped_text}'"
        end

        # Prepare the duped key to be reparented - note that root leads don't
        # have link_out_text set (the url link is applied to the title in that
        # case), so link_out_text in the inserted root lead will always be nil.
        duped_root.update!(
          text: duped_root.text.sub(dup_prefix, '(INSERTED KEY) '),
          description: nil,
          is_public: nil
        )

        add_child(duped_root)
      end
    rescue ActiveRecord::RecordNotFound => e
      errors.add(:base, "Insert key failed: #{e}")
      return false
    rescue TaxonWorks::Error => e
      errors.add(:base, "Insert key failed: #{e}")
      return false
    rescue ActiveRecord::RecordInvalid => e
      errors.add(:base, "Insert key failed: #{e}")
      return false
    end

    true
  end

  def insert_couplet
    c, d = nil, nil

    p = node_position

    t1 = 'Inserted node'
    t2 = 'Child nodes are attached to this node'

    if children.any?
      o = children.to_a

      # Reparent under left inserted node unless this is itself a right node.
      left_text = (p != :right) ? t2 : t1
      right_text = (p == :right) ? t2 : t1

      c = Lead.create!(text: left_text, parent: self)
      d = Lead.create!(text: right_text, parent: self)

      new_parent = (p != :right) ? c : d

      Lead.reparent_nodes(o, new_parent)
    else
      c = Lead.create!(text: t1, parent: self)
      d = Lead.create!(text: t1, parent: self)
    end

    [c.id, d.id]
  end

  # Destroy the children of this Lead, re-appending the grandchildren to self
  # !! Do not destroy children if more than one child has its own children
  def destroy_children
    k = children.to_a
    return true if k.empty?

    original_child_count = k.count
    grandkids = []
    k.each do |c|
      if c.children.present?
        # Fail if more than one child has its own children
        return false if grandkids.present?

        grandkids = c.children
      end
    end

    Lead.reparent_nodes(grandkids, self)

    children.slice(0, original_child_count).each do |c|
      c.destroy!
    end

    true
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
    for c in node.children.to_a.reverse # intentionally reversed
      c.all_children(c, result, depth + 1)
      a = {}
      a[:depth] = depth
      a[:lead] = c
      a[:leadLabel] = node.origin_label
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
      a[:lead] = c
      result.push(a)
    end

    for c in ch
      c.all_children_standard_key(c, result, depth + 1)
    end
    result
  end

  # @param reorder_list [Array] array of 0-based positions in which to order
  #  the children of this lead.
  # Raises TaxonWorks::Error on error.
  def reorder_children(reorder_list)
    validate_reorder_list(reorder_list, children.count)

    i = 0
    Lead.transaction do
      children.each do |c|
        if (new_position = reorder_list[i]) != i
          c.update_column(:position, new_position)
        end
        i = i + 1
      end
    end
  end

  # @return [ActiveRecord::Relation] ordered by text.
  # Returns all root nodes, with new properties:
  #  * couplets_count (declared here, computed in views)
  #  * otus_count (total number of distinct otus on the key)
  #  * key_updated_at (last time the key was updated)
  #  * key_updated_by_id (id of last person to update the key)
  #  * key_updated_by (name of last person to update the key)
  #
  # !! Note, the relation is a join, check your results when changing order
  # or plucking, most of want you want is on the table joined to, which is
  # not the default table for ordering and plucking.
  def self.roots_with_data(project_id, load_root_otus = false)
    # The updated_at subquery computes key_updated_at (and others), the second
    # query uses that to compute key_updated_by (by finding which node has the
    # corresponding key_updated_at).
    updated_at = Lead
      .joins('JOIN lead_hierarchies AS lh
        ON leads.id = lh.ancestor_id')
      .joins('JOIN leads AS otus_source
        ON lh.descendant_id = otus_source.id')
      .where("
        leads.parent_id IS NULL
        AND leads.project_id = #{project_id}
      ")
      .group(:id)
      .select('
        leads.*,
        COUNT(DISTINCT otus_source.otu_id) AS otus_count,
        MAX(otus_source.updated_at) AS key_updated_at,
        0 AS couplets_count' # count is now computed in views
        #·(COUNT(otus_source.id) - 1) / 2 AS couplet_count
      )

    root_leads = Lead
      .joins("JOIN (#{updated_at.to_sql}) AS leads_updated_at
        ON leads_updated_at.key_updated_at = leads.updated_at")
      .joins('JOIN users
        ON users.id = leads.updated_by_id')
      .select('
        leads_updated_at.*,
        leads.updated_by_id AS key_updated_by_id,
        users.name AS key_updated_by
      ')
      .order('leads_updated_at.text')

    return load_root_otus ? root_leads.includes(:otu) : root_leads
  end

  def redirect_options(project_id)
    leads = Lead
      .select(:id, :text, :origin_label)
      .with_project_id(project_id)
      .order(:text)
    anc_ids = ancestor_ids()

    leads.filter_map do |o|
      if o.id != id && !anc_ids.include?(o.id)
        {
          id: o.id,
          label: o.origin_label,
          text: o.text.nil? ? '' : o.text.truncate(40)
        }
      end
    end
  end

  private

  # Appends `nodes`` to the children of `new_parent``, in their given order.
  # !! Use this instead of add_child to reparent multiple nodes (add_child
  # doesn't work the way one might naievely expect, see the discussion at
  # https://github.com/SpeciesFileGroup/taxonworks/pull/3892#issuecomment-2016043296)
  def self.reparent_nodes(nodes, new_parent)
    last_sibling = new_parent.children.last # may be nil
    nodes.each do |n|
      if last_sibling.nil?
        new_parent.add_child(n)
      else
        last_sibling.append_sibling(n)
      end
      last_sibling = n
    end
  end

  # Raises TaxonWorks::Error on error.
  def validate_reorder_list(reorder_list, expected_length)
    if reorder_list.sort.uniq != (0..expected_length - 1).to_a
      raise TaxonWorks::Error,
        "Bad reorder list: #{reorder_list}"
      return
    end
  end

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
    a.text = "(COPY OF) #{a.text}" if parentId == nil
    a.save!

    node.children.each { |c| dupe_in_transaction(c, a.id) }
  end

  def set_is_public_only_on_root
    if parent_id.nil?
      self.is_public ||= false
    else
      self.is_public = nil
    end
  end

end
