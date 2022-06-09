# A Protocol is a recipe for how something is done.
#
# Protocols are simple records, they can be Document(ed) with
#  external files (pdfs, text files, etc.)
#
class Protocol < ApplicationRecord
  include Housekeeping
  include Shared::Documentation
  include Shared::Citations
  include Shared::IsData

  has_many :protocol_relationships, inverse_of: :protocol

  validates_presence_of :name
  validates_uniqueness_of :name, case_sensitive: false
  validates_presence_of :short_name
  validates_presence_of :description

  scope :used_on_klass, -> (klass) { joins(:protocol_relationships).where(protocol_relationships: {protocol_relationship_object_type: klass} ) } # remember to .distinct

  # TODO: unify, perhaps, with annotator logic, this is identical to Keyword methods
  # @return [Scope]
  #    the max 10 most recently used Protocols
  def self.used_recently(user_id, project_id, klass)
    t = ProtocolRelationship.arel_table
    k = self.arel_table

    # i is a select manager
    i = t.project(t['protocol_id'], t['created_at']).from(t)
      .where(t['created_at'].gt( 1.weeks.ago ))
      .where(t['created_by_id'].eq(user_id))
      .where(t['project_id'].eq(project_id))
      .order(t['created_at'].desc)

    # z is a table alias
    z = i.as('recent_t')

    used_on_klass(klass).joins(
      Arel::Nodes::InnerJoin.new(z, Arel::Nodes::On.new(z['protocol_id'].eq(k['id'])))
    ).pluck(:id).uniq
  end

  def self.select_optimized(user_id, project_id, klass)
    r = used_recently(user_id, project_id, klass)
    h = {
      quick: [],
      pinboard: Protocol.pinned_by(user_id).where(project_id: project_id).to_a,
      recent: []
    }

    if r.empty?
      h[:quick] = Protocol.pinned_by(user_id).pinboard_inserted.where(project_id: project_id).to_a
    else
      h[:recent] = Protocol.where('"protocols"."id" IN (?)', r.first(10) ).order(:name).to_a
      h[:quick] = (Protocol.pinned_by(user_id).pinboard_inserted.where(project_id: project_id).to_a +
                   Protocol.where('"protocols"."id" IN (?)', r.first(4) ).order(:name).to_a).uniq
    end

    h
  end




end
