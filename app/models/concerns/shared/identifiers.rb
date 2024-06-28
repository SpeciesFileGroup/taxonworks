# Shared code for objects that have Identifiers.
#
module Shared::Identifiers

  extend ActiveSupport::Concern
  included do
    Identifier.related_foreign_keys.push self.name.foreign_key

    # Validation happens on the parent side!
    has_many :identifiers, as: :identifier_object, validate: true, dependent: :destroy, inverse_of: :identifier_object # should be delete
    accepts_nested_attributes_for :identifiers, reject_if: :reject_identifiers, allow_destroy: true

    has_many :uuids, -> { where('identifiers.type like ?', 'Identifier::Global::Uuid%').order(:position) }, class_name: 'Identifier', as: :identifier_object
    has_many :uris, -> { where(type: 'Identifier::Global::Uri').order(:position) }, class_name: 'Identifier', as: :identifier_object

    scope :with_identifier_type, ->(identifier_type) { joins(:identifiers).where('identifiers.type = ?', identifier_type).references(:identifiers) }
    scope :with_identifier_namespace, ->(namespace_id) { joins(:identifiers).where('identifiers.namespace_id = ?', namespace_id).references(:identifiers) }

    # !! This only is able to match numeric identifiers, other results are excluded !!
    def self.with_identifiers_sorted(sort_order = 'ASC')
      raise 'illegal sort_order' if !['ASC', 'DESC'].include?(sort_order)
      includes(:identifiers)
        .where('identifiers.cached_numeric_identifier is not null')
        .order(cached_numeric_identifier: sort_order)
        .references(:identifiers)
    end

    scope :with_identifier_type_and_namespace, ->(identifier_type = nil, namespace_id = nil, sorted = nil) {
      with_identifier_type_and_namespace_method(identifier_type, namespace_id, sorted)
    }

    # Used to memoize identifier for navigating purposes
    attr_accessor :navigating_identifier

    # builds a new identifier, incremented from previous target, and assigns it to `to_object`
    # @return the identifier
    def add_incremented_identifier(to_object: nil, incremented_identifier_id: nil)
      if to_object.respond_to?(:identifiers)
        i = Identifier.find(incremented_identifier_id).dup
        i.increment_identifier
        i.identifier_object = to_object
        i.save!
      else
        false
      end
    end

    def local_identifiers
      identifiers.where("type ilike 'Identifier::Local%'")
    end
  end

  module ClassMethods
    def of_type(type_name)
      where(type: type_name)
    end

    # Exact match on identifier + namespace, return an Array, not Arel
    # @param [String, String] namespace_name is either the long or short namespace name.
    # @return [Scope]
    def with_namespaced_identifier(namespace_name, identifier)
      i = Identifier.arel_table
      n = Namespace.arel_table
      s = self.arel_table

      # conditions
      c1 = n[:name].eq(namespace_name).or(n[:short_name].eq(namespace_name))
      c2 = i[:identifier].eq(identifier)

      # join identifiers to namespaces
      j = i.join(n).on(i[:namespace_id].eq(n[:id]))

      # join self to identifiers
      l = s.join(i).on(s[:id].eq(i[:identifier_object_id]).and(i[:identifier_object_type].eq(self.base_class.name)))

      self.joins(l.join_sources, j.join_sources).where(c1.and(c2).to_sql)
    end

    # Exact match on the full identifier (use for any class of identifiers)
    # 'value' is the cached value with includes the namespace (see spec)
    # example Serial.with_identifier('MX serial ID 8740')
    def with_identifier(value)
      value = [value] if value.class == String
      t = Identifier.arel_table
      a = t[:cached].in(value)
      self.joins(:identifiers).where(a.to_sql).references(:identifiers)
    end

    # @param sorted ['ASC', 'DESC', nil]
    # @param identifier_type [like 'Identifier::Local::TripCode', nil]
    # @param namespace_id [Integer, nil]
    # !! Note that adding a sort also adds a where clause that constrains results to those that have numeric identifier.identifier
    def with_identifier_type_and_namespace_method(identifier_type, namespace_id, sorted = nil)
      return self.none if identifier_type.blank? && namespace_id.blank? && sorted.blank?
      q = nil
      q = with_identifier_type(identifier_type) if identifier_type.present?
      q = (!q.nil? ? q.with_identifier_namespace(namespace_id) :  with_identifier_namespace(namespace_id) ) if namespace_id.present?
      q = (!q.nil? ? q.with_identifiers_sorted(sorted) :  with_identifiers_sorted(sorted) ) if sorted.present?
      q
    end
  end

  def uri
    uris.first&.cached
  end

  def uuid
    uuids.first&.cached
  end

  def dwc_occurrence_id
    identifiers.where('identifiers.type like ?', 'Identifier::Global::Uuid%').order('identifiers.position ASC').first&.identifier
  end

  def identified?
    if respond_to?(:project_id)
      identifiers.visible(self.project_id).any?
    else
      identifiers.any?
    end
  end

  def next_by_identifier
    # TODO: Memoize i so it can be shared with previous etc.
    # LIke attr_accessor @navigating_identifier
    if @navigating_identifier ||= identifiers.where("identifiers.type ILIKE 'Identifier::Local%'").order(:position).first
      self.class
        .where(project_id:)
        .where.not(id:)
        .with_identifier_type_and_namespace_method(navigating_identifier.type, navigating_identifier.namespace_id, 'ASC')
        .where('cached_numeric_identifier > ?', navigating_identifier.cached_numeric_identifier)
        .first
    else
      nil
    end
  end

  def previous_by_identifier
    if @navigating_identifier ||= identifiers.where("type ILIKE 'Identifier::Local%'").order(:position).first
      self.class
        .where(project_id:)
        .where.not(id:)
        .with_identifier_type_and_namespace_method(navigating_identifier.type, navigating_identifier.namespace_id, 'DESC')
        .where('cached_numeric_identifier < ?', navigating_identifier.cached_numeric_identifier)
        .first
    else
      nil
    end

  end

  protected

  def reject_identifiers(attributed)
    attributed['identifier'].blank? || attributed['type'].blank?
  end

end
