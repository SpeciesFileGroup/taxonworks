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

  include Shared::BatchByFilterScope
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

  scope :visible, -> (project_id) { where(visible_predicate(project_id)) }

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

  # !! Keep in sync with visible_to_project?
  def self.visible_predicate(project_id)
    arel_table[:project_id].eq(project_id)
      .or(arel_table[:type].matches('Identifier::Global%'))
  end

  # !! Keep in sync with visible_predicate
  def visible_to_project?(project_id)
    type.to_s.start_with?('Identifier::Global') || project_id == self.project_id
  end

  def self.namespaces_for_types_from_query(identifier_types, query)
    q = ::Queries::Query::Filter.instantiated_base_filter(query)
    @namespaces = q.all
      .joins(identifiers: :namespace)
      .where(identifiers: {type: identifier_types})
      .select('namespaces.short_name, namespaces.verbatim_short_name')
      .order('namespaces.short_name')
      .distinct
      .pluck('namespaces.id', 'namespaces.short_name', 'namespaces.verbatim_short_name', 'is_virtual')
      .map { |id, short_name, verbatim_short_name, is_virtual| {
        id:, short_name:, verbatim_short_name:, is_virtual:
      }}
  end

  def self.process_batch_by_filter_scope(
    batch_response: nil, query: nil, hash_query: nil, mode: nil, params: nil,
    async: nil, project_id: nil, user_id: nil,
    called_from_async: false
  )
    # Don't call async from async (the point is we do the same processing in
    # async and not in async, and this function handles both that processing and
    # making the async call, so it's this much janky).
    async = false if called_from_async == true
    r = batch_response

    # TODO: make sure params.identifier_types are actually allowed on klass
    if params[:namespace_id].nil?
      r.errors['replacement namespace id not provided'] = 1
      return
    elsif params[:identifier_types].empty?
      r.errors['no identifier types provided'] = 1
      return r
    elsif params[:virtual_namespace_prefix] && Namespace.find(params[:namespace_id]).is_virtual
      r.errors["Can't currently delete virtual prefix and change to virtual namespace"] = 1
      return r
    elsif params[:namespaces_to_replace].empty?
      r.errors['no namespaces to replace'] = 1
      return r
    end

    case mode.to_sym
    when :replace
      if params[:namespace_id].nil?
        r.errors['no replacement namespace id provided'] = 1
        return r.to_json
      end

      if async && !called_from_async
        BatchByFilterScopeJob.perform_later(
          klass: self.name,
          hash_query: hash_query,
          mode:,
          params:,
          project_id:,
          user_id:
        )
      else
        prefix = params[:virtual_namespace_prefix]
        Identifier
          .with(a: query.select(:id))
          .joins('JOIN a ON identifiers.identifier_object_id = a.id AND ' \
                 "identifiers.identifier_object_type = '#{query.klass}'")
          .where(type: params[:identifier_types])
          .joins(:namespace)
          .where(namespaces: { id: params[:namespaces_to_replace] })
          .select('identifiers.*, namespaces.is_virtual AS is_virtual')
          #.where.not(namespace_id: params.namespace_id)
          .distinct
          .find_each do |o|
            if params[:virtual_namespace_prefix]
              if (
                o.is_virtual &&
                o.identifier.start_with?(prefix) &&
                o.identifier.length > prefix.length
              )
                o.identifier = o.identifier.delete_prefix(prefix)
                o.namespace_id = params[:namespace_id]

                if o.save
                  r.updated.push o.id
                else
                  r.not_updated.push o.id
                end
              else # this identifier is excluded by virtual_namespace_prefix
                r.not_updated.push o.id
              end
            else # no virtual worries, just namespace_id replacement
              o.namespace_id = params[:namespace_id]

              if o.save
                r.updated.push o.id
              else
                r.not_updated.push o.id
              end
            end
          end
      end
    end

    r.total_attempted = r.updated.length + r.not_updated.length
    return r
  end

  protected

  # See subclasses
  def build_cached
    nil
  end

  def build_cached_numeric_identifier
    return nil if is_global?
    re = if is_local? && is_virtual?
           /[\d\.\,]+\z/ # namespace prefix allowed
         else
           /\A[\d\.\,]+\z/ # only 'numeric' supported
         end

    if a = identifier.match(re)
      b = a[0].to_s.gsub(',', '')
      b.to_f
    else
      nil
    end
  end

  def set_cached
    # build_cached_numeric_identifier uses the value of #cached, so update it
    # locally first.
    self.cached = build_cached
    update_columns(
      cached:,
      cached_numeric_identifier: build_cached_numeric_identifier
    )
  end
end

#Rails.application.reloader.to_prepare do
Dir[Rails.root.to_s + '/app/models/identifier/**/*.rb'].sort.each{ |file| require_dependency file }
# aned
