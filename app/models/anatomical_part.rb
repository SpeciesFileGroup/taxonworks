# A lightweight but extensible reference to anatomy. It refers to physical
# objects as instances or concepts (see is_material) The concept is a data node,
# with inference happening if/when linkages to an Ontology exist. I.e. we are
# storing only very light-weight data.
# Use cases:
#   * Collector goes to field, takes a punch of a fish fin, and returns it ->
#     AnatomicalPart has_origin FieldOccurrence
#   * A wing is dissected from a specimen -> AnatomicalPart has_origin Specimen
#   * A feather is removed from a bird, and a punch from the feather ->
#     AnatomicalPart has_origin AnatomicalPart has_origin FieldOccurrence
#   * A louse is collected from the Ear of a bat, the louse is collected, the
#     Bat is not - AnatomicalPart (ear) has_origin FieldOCcurrence (bat) ->
#     BiologicalAssociation <- CollectionObject (louse)
#
# @!attribute name
#   @return [String]
#   Name of the anatomical part.
#
# @!attribute uri
#   @return [String]
#   Ontology uri of the anatomical part.
#
# @!attribute uri_label
#   @return [String]
#   Uri label of the uri for the anatomical part.
#
# @!attribute is_material
#   @return [Boolean]
#   Whether or not the anatomical part is based on a physical object - *a* head
#   vs. *some* head.
#
# @!attribute preparation_type_id
#   @return [Integer]
#   Preparation type of this part.
#
# @!cached_otu_id
#   @return [Integer]
#   Each anatomical part is required to have an originRelationship-ancestor that
#   is either an Otu or has a determination with an Otu. This is that Otu.
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
class AnatomicalPart < ApplicationRecord
  include Housekeeping
  include Shared::Uri
  include Shared::Citations
  include Shared::Confidences
  include Shared::DataAttributes
  include Shared::Depictions
  include Shared::Conveyances
  include Shared::HasPapertrail
  include Shared::Identifiers
  # Override the :uri defined by Identifiers. Bad.
  def uri
    self[:uri]
  end
  include Shared::Loanable
  include Shared::BiologicalAssociations
  include Shared::Taxonomy
  include Shared::Notes
  include Shared::Observations
  include Shared::Containable
  include Shared::OriginRelationship
  include Shared::ProtocolRelationships
  include Shared::Tags
  include Shared::PurlDeprecation
  include Shared::IsData

  is_origin_for 'AnatomicalPart', 'Extract', 'Sequence', 'Sound'
  originates_from 'Otu', 'Specimen', 'Lot', 'CollectionObject', 'AnatomicalPart', 'FieldOccurrence'

  GRAPH_ENTRY_POINTS = [:origin_relationships]

  attr_accessor :origin_object # origin of this part, only used on create
  attr_accessor :no_cached

  belongs_to :origin_otu, class_name: 'Otu', foreign_key: :cached_otu_id, inverse_of: :anatomical_parts
  belongs_to :preparation_type, inverse_of: :anatomical_parts

  # Needed so we can build the origin chain at the same time we're using it to
  # verify that a new AnitomicalPart has an OTU ancestor.
  # Probably not needed outside of creation.
  has_one :inbound_origin_relationship,
    -> { where(new_object_type: 'AnatomicalPart') },
    as: :new_object,
    class_name: 'OriginRelationship',
    inverse_of: :new_object

  accepts_nested_attributes_for :inbound_origin_relationship

  # Must run before associated origin_relationships are destroyed.
  before_destroy :abort_if_has_descendant_anatomical_part, prepend: true
  around_destroy :setOriginRelationshipDestroyContext, prepend: true

  after_save :set_cached, unless: -> { self.no_cached }
  # Runs in the update transaction, so any errors will abort the udpate.
  after_update :propagate_change_to_is_material!, if: :saved_change_to_is_material?

  validates :inbound_origin_relationship, presence: true, on: :create
  validate :name_or_uri_not_both
  validate :top_origin_is_valid_origin
  validate :is_material_matches_origin
  validate :is_material_matches_parent_anatomical_part

  # Callback on OriginRelationship#create
  def allow_origin_relationship_create?(origin_relationship)
    # Disallow if we already have a parent.
    return false if origin_relationship.new_object == self &&
      OriginRelationship.where(new_object: self).exists?

    true
  end

  # Callback on OriginRelationship#destroy
  def allow_origin_relationship_destroy?(origin_relationship)
    # Allow if we originated the destroy because we're being destroyed (relies
    # on abort_if_has_descendant_anatomical_part to catch cases where that
    # shouldn't be allowed).
    return true if OriginRelationshipDestroyContext.objects_in_destroy&.include?({
      id:, type: 'AnatomicalPart'
    })

    # Disallow if origin_relationship is part of our required ancestry chain.
    return false if origin_relationship.new_object == self

    true
  end

  # @return [Scope]
  #    the max 10 most recently used anatomical_parts
  def self.used_recently(user_id, project_id, used_on = '')
    old_types = valid_old_object_classes
    new_types = valid_new_object_classes
    return [] if !old_types.include?(used_on) && !new_types.include?(used_on)

    t = used_on.constantize.arel_table
    i = t[:updated_at].gt(1.week.ago)
      .and(t[:updated_by_id].eq(user_id))
      .and(t[:project_id].eq(project_id))

    p = AnatomicalPart.arel_table
    o = OriginRelationship.arel_table

    related = used_on.tableize
    related_klass = used_on
    if old_types.include?(used_on) && new_types.include?(used_on)
      a = AnatomicalPart.joins(:related_origin_relationships).joins("JOIN #{related} AS t1 ON t1.id = origin_relationships.old_object_id AND origin_relationships.old_object_type = '#{related_klass}'").where(i)

      b = AnatomicalPart.joins(:origin_relationships).joins("JOIN #{related} AS t2 ON t2.id = origin_relationships.new_object_id AND origin_relationships.new_object_type = '#{related_klass}'").where(i)

      ::Queries.union(AnatomicalPart, [a,b]).pluck(:id).uniq
    elsif old_types.include?(used_on)
      AnatomicalPart.joins(:related_origin_relationships).joins("JOIN #{related} ON #{related}.id = origin_relationships.old_object_id AND origin_relationships.old_object_type = '#{related_klass}'").where(i).pluck(:id).uniq
    else
      AnatomicalPart.joins(:origin_relationships).joins("JOIN #{related} ON #{related}.id = origin_relationships.new_object_id AND origin_relationships.new_object_type = '#{related_klass}'").where(i).pluck(:id).uniq
    end
  end

  # @return [Hash] anatomical_parts optimized for user selection
  def self.select_optimized(user_id, project_id, target = nil)
    r = used_recently(user_id, project_id, target)
    h = {
      quick: [],
      pinboard: AnatomicalPart.pinned_by(user_id).where(project_id:).to_a,
      recent: []
    }

    if target && !r.empty?
      n = target.tableize.to_sym
      h[:recent] = AnatomicalPart.where('"anatomical_parts"."id" IN (?)', r.first(10) ).to_a
      h[:quick] = (AnatomicalPart.pinned_by(user_id).pinboard_inserted.where(project_id:).to_a  +
        AnatomicalPart.where('"anatomical_parts"."id" IN (?)', r.first(4) ).to_a).uniq
    else
      h[:recent] = AnatomicalPart.where(project_id:, updated_by_id: user_id).order('updated_at DESC').limit(10).to_a
      h[:quick] = AnatomicalPart.pinned_by(user_id).pinboard_inserted.where(project_id:).to_a
    end

    h
  end

  def self.graph(id, type)
    case type
    when *(AnatomicalPart.valid_old_object_classes - ['AnatomicalPart'])
      construct_graph_from_top_node(id, type)
    when *(AnatomicalPart.valid_new_object_classes - ['AnatomicalPart'])
      construct_graph_from_low_node(id, type)
    when 'AnatomicalPart'
      part = AnatomicalPart.find(id)
      origin = part.taxonomic_origin_object
      # This constructs the full graph starting from origin - if we decide we
      # only want the chain containing the original input then call
      # graph_from_mid_node instead.
      construct_graph_from_top_node(origin.id, origin.class.base_class.name)
    end
  end

  # The top object in the OriginRelationship chain.
  def taxonomic_origin_object
    return @top_origin_object if @top_origin_object.present?

    origin = inbound_origin_relationship
    return nil if origin.nil? # invalid object

    next_parent = nil
    while (next_parent = OriginRelationship.where(new_object_id: origin.old_object_id, new_object_type: origin.old_object_type).first)
      origin = next_parent
    end

    @top_origin_object = origin.old_object
    @top_origin_object
  end

  def containable?
    is_material
  end

  private

  def set_cached
    update_column(:cached, name || uri_label)

    # cached_otu_id is determined by external objects, so is never changed by an
    # update, only a create.
    return if cached_otu_id

    top_origin = taxonomic_origin_object

    if top_origin.class.name == 'Otu'
      update_column(:cached_otu_id, top_origin.id)
    else
      update_column(:cached_otu_id, top_origin.current_otu.id)
    end
  end

  def name_or_uri_not_both
    has_labelled_uri = uri.present? && uri_label.present?
    return if has_labelled_uri && !name.present?
    return if name.present? && !uri.present? && !uri_label.present?

    errors.add(:base, 'Exactly one of 1) name, or 2) uri *and* uri_label, must be present')
  end

  def top_origin_is_valid_origin
    origin = taxonomic_origin_object

    errors.add(:base, 'Anatomical parts must be endpoints of an OriginRelationship!') && return if origin.nil?

    valid = valid_old_object_classes - ['AnatomicalPart']
    t = origin.class.base_class.name
    errors.add(:base, "Class of original origin must be in [#{valid.join(', ')}], not #{t}") && return if !valid.include?(t)

    return if origin.class.name == 'Otu'

    errors.add(:base, "Original origin must have a taxon determination!") && return if !origin.taxon_determinations.exists?
  end

  def is_material_matches_origin
    origin = taxonomic_origin_object
    return if origin.nil? # invalid

    if origin.class.base_class.name == 'CollectionObject' && is_material != true
      errors.add(:base, 'CollectionObject parts must have is_material true!')
      return
    elsif origin.class.base_class.name == 'Otu' && is_material == true
      errors.add(:base, 'OTU parts must have is_material false!')
      return
    end
  end

  def is_material_matches_parent_anatomical_part
    return if inbound_origin_relationship.nil? # invalid
    parent = inbound_origin_relationship.old_object
    return if parent.class.name != 'AnatomicalPart'

    if parent.is_material != is_material
      errors.add(:base, 'is_material must match parent value!')
    end
  end

  def propagate_change_to_is_material!
    # is_material can only be changed on the top AnatomicalPart, so change the
    # value on all AnatomicalPart descendants.
    new_is_material = is_material
    current = [self]

    while(current.present?)
      nxt = []
      current.each do |o|
        o.update_column(:is_material, new_is_material)
        nxt += o.new_objects
      end

      current = nxt.filter { |x| x.class.name == 'AnatomicalPart' }
    end

  end

  # Construct an AnatomicalPart graph starting from an AnatomicalPart. Going up
  # the graph is a chain ending in the source of the AnatomicalPart, going down
  # we include everything, even after we no longer see AnatomicalParts.
  def self.construct_graph_from_mid_node(anatomical_part_id, forward_only: false)
    nodes = []
    origin_relationships = []

    origin = AnatomicalPart.find(anatomical_part_id)
    current = [origin]

    # Go down the graph: going down we show everything, since it all has origin
    # some anatomical part.
    while(current.present?)
      nxt = []
      current.each do |o|
        nodes << o
        # No restriction on old_object_type.
        r = OriginRelationship.where(old_object: o)
        origin_relationships += r
        nxt += o.new_objects
      end

      current = nxt
    end

    # Go up the graph (chain).
    if !forward_only
      current = origin
      while (current.present? && current.class.name == 'AnatomicalPart')
        r = OriginRelationship.where(new_object_id: current.id, new_object_type: 'AnatomicalPart').first
        if r.present?
          origin_relationships << r
          nodes << current.old_objects.first
        end

        current = current.old_objects.first
      end
    end

    return nodes, origin_relationships
  end

  # Construct anatomical part graph starting at a top node, like
  # CollectionObject, FieldOccurrence, OTU. This returns *all* AnatomicalPart
  # children of the top node.
  def self.construct_graph_from_top_node(node_id, node_type)
    origin = node_type.constantize.find(node_id)
    r = OriginRelationship
      .where(
        old_object_id: node_id,
        old_object_type: node_type,
        new_object_type: 'AnatomicalPart'
      )

    origin_relationships = r
    nodes = [origin]
    r.each do |rln|
      anatomical_part = rln.new_object
      new_nodes, new_origin_relationships = construct_graph_from_mid_node(
        anatomical_part.id, forward_only: true
      )
      nodes += new_nodes
      origin_relationships += new_origin_relationships
    end

  return nodes, origin_relationships
  end

  # Construct an AnatomicalPart graph starting from the direct
  # non-anatomical-part child of an anatomical part, like an Extract or a Sound.
  # @param node_type is *not* AnatomicalPart, but we assume its origin *is*.
  def self.construct_graph_from_low_node(node_id, node_type)
    origin = node_type.constantize.find(node_id)
    r = OriginRelationship
      .where(
        new_object_id: node_id,
        new_object_type: node_type,
        old_object_type: 'AnatomicalPart'
      )

    anatomical_part = r.first&.old_object # reverse paths are always a chain (for anatomical parts)

    nodes = [origin]
    origin_relationships = []
    if anatomical_part
      # This can return more children of anatomical_part than just node.
      nodes, origin_relationships = construct_graph_from_mid_node(
        anatomical_part.id
      )
    end

    return nodes, origin_relationships
  end

  def abort_if_has_descendant_anatomical_part
    if OriginRelationship.where(old_object: self).exists?
      errors.add(:base, "This part can't be deleted because it's not the end of an AnatomicalPart chain.")
      throw(:abort)
    end
  end

  def setOriginRelationshipDestroyContext
    OriginRelationshipDestroyContext.objects_in_destroy ||= Set.new
    OriginRelationshipDestroyContext.objects_in_destroy << {
      id:, type: 'AnatomicalPart'
    }

    yield

  ensure
    OriginRelationshipDestroyContext.objects_in_destroy.delete({
      id:, type: 'AnatomicalPart'
    })
  end
end
