# A lightweight but extensible reference to anatomy. It refers to physical
# objects as instances or concepts (see is_material) The concept is a data node,
# with inference happening if/when linkages to an Ontology exist. I.e. we are
# storing only very light-weight data.
# Use cases:
#     Collector goes to field, takes a punch of a fish fin, and returns it ->
#     AnatomicalPart has_origin FieldOccurrence A wing is dissected from a
#     specimen -> AnatomicalPart has_origin Specimen A feather is removed from a
#     bird, and a punch from the feather -> AnatomicalPart has_origin
#     AnatomicalPart has_origin FieldOccurrence A louse is collected from the
#     Ear of a bat, the louse is collected, the Bat is not - AnatomicalPart
#     (ear) has_origin FieldOCcurrence (bat) -> BiologicalAssociation <-
#     CollectionObject (louse)
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
# @!cached
#   @return [String]
#
# @!taxonomic_origin_object_id
#   @return [Integer]
#   Polymorhpic object id of the root of the directed tree this anatomical part
#   belongs to. Provides the relation of this part to taxonomy.
#
# @!taxonomic_origin_object_type
#   @return [String]
#   Polymorphic bject type of the root of the directed tree this anatomical part
#   belongs to. Provides the relation of this part to taxonomy.
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
  include Shared::Loanable
  include Shared::BiologicalAssociations
  include Shared::Taxonomy
  include Shared::Notes
  include Shared::Observations
  include Shared::Containable
  include Shared::OriginRelationship
  include Shared::ProtocolRelationships
  include Shared::Tags
  include Shared::IsData
  include SoftValidation
  include Shared::PolymorphicAnnotator
  polymorphic_annotates('taxonomic_origin_object')

  is_origin_for 'AnatomicalPart', 'Extract', 'Sequence', 'Sound'
  originates_from 'Otu', 'Specimen', 'Lot', 'CollectionObject', 'AnatomicalPart', 'FieldOccurrence'

  GRAPH_ENTRY_POINTS = [:origin_relationships]

  attr_accessor :no_cached

  belongs_to :taxonomic_origin_object, polymorphic: true, inverse_of: :anatomical_parts

  after_save :set_cached, unless: -> { self.no_cached }

  validate :name_or_uri_not_both
  validate :taxonomic_origin_object_is_valid_type
  validate :taxonomic_origin_object_relates_to_otu

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
    when *AnatomicalPart.valid_old_object_classes.reject { |c| c == 'AnatomicalPart' }
      construct_graph_from_top_node(id, type)
    when *AnatomicalPart.valid_new_object_classes.reject { |c| c == 'AnatomicalPart' }
      construct_graph_from_low_node(id, type)
    when 'AnatomicalPart'
      construct_graph_from_mid_node(id)
    end
  end

  private

  def set_cached
    # TODO
    update_column(:cached, name)
  end

  def name_or_uri_not_both
    has_labelled_uri = uri.present? && uri_label.present?
    return if has_labelled_uri && !name.present?
    return if name.present? && !has_labelled_uri

    errors.add(:base, 'Exactly one of 1) name, or 2) uri *and* uri_label, must be present')
  end

  def taxonomic_origin_object_is_valid_type
    return if taxonomic_origin_object.nil?
    valid = ['Otu', 'CollectionObject', 'FieldOccurrence']
    t = taxonomic_origin_object.class.base_class.name
    return if valid.include?(t)

    errors.add(:base, "Class of taxonomic_origin_object must be in [#{valid.join(', ')}], not #{t}")
  end

  def taxonomic_origin_object_relates_to_otu
    return if taxonomic_origin_object.nil?
    t = taxonomic_origin_object.class.base_class.name
    return if t == 'Otu' || taxonomic_origin_object.taxon_determinations.exists?

    errors.add(:base, 'taxonomic_origin_object is required to have a taxon determination')
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
        r = OriginRelationship.where(old_object_id: o.id)
        origin_relationships = origin_relationships + r
        nxt = nxt + o.new_objects
      end

      current = nxt
      puts nxt
    end

    # Go up the graph (chain).
    if !forward_only
      current = origin
      while (current.present?)
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
    r.each do |r|
      anatomical_part = r.new_object
      new_nodes, new_origin_relationships = construct_graph_from_mid_node(
        anatomical_part.id, forward_only: true
      )
      nodes = nodes + new_nodes
      origin_relationships = origin_relationships + new_origin_relationships
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
end
