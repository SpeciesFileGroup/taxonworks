# An Identifier is the information that can be use to differentiate concepts.
# If an identifier differentiates individuals of all types it is "Global".
# If an identifier differentiates individuals of one type, within a specific subset of that type, it is "Local".
#
# Local identifiers have a namespace, a string that preceeds the variable portion of the identifier.
#
# Note this definition is presently very narrow, and that an identifier
# can in practice be used for a lot more than differentiation (i.e.
# it can often be resolved etc.).
#
# !! Identifiers should always be created in the context of the the object they identify, see spec/lib/identifier_spec.rb for examples  !!
#
#
# @!attribute identifier
#   @return [String]
#   The string identifying the object.  Must be unique within the Namespace if provided.
#   Same as http://rs.tdwg.org/dwc/terms/catalogNumber, but broadened in scope to be used for any data.
#
# @!attribute type
#   @return [String]
#   The Rails STI subclass of this identifier.
#
# @!attribute namespace_id
#   @return [Integer]
#   The Namespace for this identifier.
#
# @!attribute project_id
#   @return [Integer]
#   The project ID.
#
# @!attribute identifier_object_id
#   @return [Integer]
#   The id of the identified object, used in a polymorphic relationship.
#
# @!attribute identifier_object_type
#   @return [String]
#   The type of the identified object, used in a polymorphic relationship.
#
# @!attribute cached
#   @return [String]
#   The full identifier, for display, i.e. namespace + identifier (local), or identifier (global).
#
# @!attribute cached_numeric_identifier
#   @return [Float, nil]
#     If `identifier` contains a numeric string, then record this as a float.
#     !! This should never be exposed, it's used for internal next/previous options only.
#  See `build_cached_numeric_identifier`.
#     This does account for identifiers like:
#       123,123
#       123,123.12
#       123.12
#       .12
#     This does not account for identifiers like (though this could be hacked in if it becomes necessary by ordering alphanumerics into decimal additions to the float):
#       123,123a
#       123a
#       123.123a
#
class Identifier < ApplicationRecord
  acts_as_list scope: [:project_id, :identifier_object_type, :identifier_object_id ], add_new_at: :top

  include Shared::DualAnnotator
  include Shared::PolymorphicAnnotator

  polymorphic_annotates('identifier_object')

  include Housekeeping # TODO: potential circular dependency constraint when this is before above.
  include Shared::Labels
  include Shared::IsData

  after_save :set_cached, unless: Proc.new {|n| errors.any? }

  belongs_to :namespace, inverse_of: :identifiers  # only applies to Identifier::Local, here for create purposes

  validates :type, :identifier, presence: true

  validates :identifier, presence: true

  # TODO: DRY to IsData? Test.
  scope :with_type_string, -> (base_string) {where('type LIKE ?', "#{base_string}")}

  scope :prefer, -> (type) { order(Arel.sql(<<~SQL)) }
    CASE WHEN identifiers.type = '#{type}' THEN 1 \
    WHEN identifiers.type != '#{type}' THEN 2 END ASC, \
    position ASC
  SQL

  scope :visible, -> (project_id) { where("identifiers.project_id = ? OR identifiers.type ILIKE 'Identifier::Global%'", project_id) }

  scope :local, -> {where("identifiers.type ILIKE 'Identifier::Local%'") }
  scope :global, -> {where("identifiers.type ILIKE 'Identifier::Global%'") }

  # @return [String, Identifer]
  def self.prototype_identifier(project_id, created_by_id)
    identifiers = Identifier.where(project_id:, created_by_id:).limit(1)
    identifiers.empty? ? '12345678' : identifiers.last.identifier
  end

  # @return [String]
  def type_name
    self.class.name.demodulize.downcase
  end

  def is_local?
    false
  end

  def is_global?
    false
  end

  def self.namespaces_for_types_from_query(identifier_types, query)
    q = ::Queries::Query::Filter.instantiated_base_filter(query)
    @namespaces = q.all
      .joins(identifiers: :namespace)
      .where(identifiers: {type: identifier_types})
      .select('namespaces.short_name')
      .order('namespaces.short_name')
      .distinct
      .pluck(:short_name)
  end

  def self.batch_by_filter_scope(
    filter_query: nil, params: nil, mode: :add, async_cutoff: 300,
    project_id: nil, user_id: nil
  )
    params = params.to_h.symbolize_keys

    r = ::BatchResponse.new(
      preview: false,
      method: 'Identifier batch_by_filter_scope',
    )

    # TODO: make sure params.identifier_types are actually allowed on klass
    if filter_query.nil?
      r.errors['scoping filter not provided'] = 1
      return r
    elsif params[:namespace_id].nil?
      r.errors['replacement namespace id not provided'] = 1
    elsif params[:identifier_types].empty?
      r.errors['no identifier types provided'] = 1
    end

    b = ::Queries::Query::Filter.instantiated_base_filter(filter_query)
    q = b.all(true)

    fq = ::Queries::Query::Filter.base_query_to_h(filter_query)

    r.klass =  b.referenced_klass.name

    if b.only_project?
      r.total_attempted = 0
      r.errors['can not update records without at least one filter parameter'] = 1
      return r
    end

    c = q.count
    async = c > async_cutoff ? true : false

    r.total_attempted = c
    r.async = async

    case mode.to_sym
    when :replace
      if params[:namespace_id].nil?
        r.errors['no replacement namespace id provided'] = 1
        return r.to_json
      end

      if async
        IdentifierBatchJob.perform_later(
          filter_query: fq,
          params:,
          mode: :replace,
          project_id:,
          user_id:
        )
      else
        klass = b.referenced_klass.name
        Identifier
          .with(a: q.select(:id))
          .joins('JOIN a ON identifiers.identifier_object_id = a.id AND ' \
                 "identifiers.identifier_object_type = '#{klass}'")
          .where(type: params[:identifier_types])
          #.where.not(namespace_id: params.namespace_id)
          .distinct
          .find_each do |o|
            o.update(namespace_id: params[:namespace_id])
            if o.valid?
              r.updated.push o.id
            else
              r.not_updated.push nil
            end
          end
      end
    end

    return r.to_json
  end

  protected

  # See subclasses
  def build_cached
    nil
  end

  def build_cached_numeric_identifier
    return nil if is_global?
    if a = identifier.match(/\A[\d\.\,]+\z/)
      b = a.to_s.gsub(',', '')
      b.to_f
    else
      nil
    end
  end

  def set_cached
    update_columns(
      cached: build_cached,
      cached_numeric_identifier: build_cached_numeric_identifier
    )
  end
end

#Rails.application.reloader.to_prepare do
Dir[Rails.root.to_s + '/app/models/identifier/**/*.rb'].sort.each{ |file| require_dependency file }
# aned
