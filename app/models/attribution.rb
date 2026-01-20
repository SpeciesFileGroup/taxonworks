# An attribution is an explicit assertion of who is responsible for different attributes of the content of tied data.
#
# @!attribute copyright_year
#   @return [Integer]
#     4 digit year of copyright
#
# @!attribute license
#   @return [String]
#     A creative-commons copyright
#
# @!attribute attribution_object_type
#   @return [String]
#     Polymorphic attribution object type
#
# @!attribute attribution_object_id
#   @return [Integer]
#     Polymorphic attribution object id
class Attribution < ApplicationRecord
  include Housekeeping
  include Shared::BatchByFilterScope
  include Shared::Notes
  include Shared::Confidences
  include Shared::Tags
  include Shared::IsData
  include Shared::PolymorphicAnnotator
  polymorphic_annotates('attribution_object', inverse_of: :attribution)

  # TODO: Consider DRYing with Source roles.

  ATTRIBUTION_ROLES = [
    :creator,
    :editor,
    :owner,
    :copyright_holder
  ].freeze

  ATTRIBUTION_ROLES.each do |r|
    role_name = "#{r}_roles".to_sym
    role_person = "attribution_#{r.to_s.pluralize}".to_sym
    role_organization = "attribution_organization_#{r.to_s.pluralize}".to_sym

    has_many role_name, -> { order('roles.position ASC') }, class_name: "Attribution#{r.to_s.camelize}", as: :role_object, inverse_of: :role_object
    has_many role_person, -> { order('roles.position ASC') }, through: role_name, source: :person, validate: true
    has_many role_organization, -> { order('roles.position ASC') }, through: role_name, source: :organization, validate: true

    accepts_nested_attributes_for role_name, allow_destroy: true
    accepts_nested_attributes_for role_person
    accepts_nested_attributes_for role_organization
  end

  validates :attribution_object_id, uniqueness: { scope: [:attribution_object_type, :project_id] }

  validates :license, inclusion: {in: CREATIVE_COMMONS_LICENSES.keys}, allow_nil: true

  validates :copyright_year, date_year: {
    min_year: 1000, max_year: Time.zone.now.year + 5,
    message: 'must be an integer greater than 999 and no more than 5 years in the future'}

  validate :some_data_provided

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

    case mode.to_sym
    when :add
      attribution = params[:attribution].presence || {}

      unless attribution_data_present?(attribution)
        r.errors['no attribution provided'] = 1
        return r
      end

      if async && !called_from_async
        BatchByFilterScopeJob.perform_later(
          klass: self.name,
          hash_query:,
          mode:,
          params:,
          project_id:,
          user_id:
        )
      else
        attribution_object_type = query.klass.name
        query.find_each do |o|
          existing = Attribution.find_by(
            attribution_object_id: o.id,
            attribution_object_type:
          )
          if existing
            result = apply_add_attribution(existing, attribution)
            if result == :updated
              r.updated.push existing.id
            else
              r.not_updated.push existing.id
            end
          else
            o_params = attribution.merge({
              attribution_object_id: o.id,
              attribution_object_type:
            })
            created = Attribution.create(o_params)

            if created.valid?
              r.updated.push created.id
            else
              r.not_updated.push nil # no id to add
            end
          end
        end
      end

    when :remove
      attribution = params[:attribution].presence || {}

      unless attribution_data_present?(attribution)
        r.errors['no attribution criteria provided'] = 1
        return r
      end

      if async && !called_from_async
        BatchByFilterScopeJob.perform_later(
          klass: self.name,
          hash_query:,
          mode:,
          params:,
          project_id:,
          user_id:
        )
      else
        attribution_scope_for(query, attribution).find_each do |o|
          result = apply_remove_attribution(o, attribution)
          if result == :updated || result == :destroyed
            r.updated.push o.id
          else
            r.not_updated.push o.id
          end
        end
      end

    when :replace
      replace_attribution = params[:replace_attribution].presence || {}
      to_attribution = params[:attribution].presence || {}

      unless attribution_data_present?(replace_attribution)
        r.errors['no replace attribution criteria provided'] = 1
        return r
      end

      unless attribution_data_present?(to_attribution)
        r.errors['no replacement attribution provided'] = 1
        return r
      end

      if async && !called_from_async
        BatchByFilterScopeJob.perform_later(
          klass: self.name,
          hash_query:,
          mode:,
          params:,
          project_id:,
          user_id:
        )
      else
        attribution_scope_for(query, replace_attribution).find_each do |o|
          result = apply_replace_attribution(o, replace_attribution, to_attribution)
          if result == :updated || result == :destroyed
            r.updated.push o.id
          else
            r.not_updated.push o.id
          end
        end
      end
    end

    r
  end

  protected

  def some_roles_present
    ATTRIBUTION_ROLES.each do |r|
      return true if send("#{r}_roles".to_sym).any?
    end

    if self.roles.any?
      self.roles.each do |r|
        return true if r.type.present? && (r.person_id.present? || r.organization_id.present?)
      end
    end

    false
  end

  def some_data_provided
    if license.blank? && copyright_year.blank? && !some_roles_present
      errors.add(:base, 'no attribution metadata')
    end
  end

  private

    def self.attribution_data_present?(attribution)
    attrs = attribution.to_h.symbolize_keys
    roles = attribution_roles(attrs)

    attrs[:license].present? || attrs[:copyright_year].present? || roles.any?
  end

  def self.attribution_roles(attribution)
    attrs = attribution.to_h.symbolize_keys
    roles = attrs[:roles_attributes] || []

    Array(roles)
      .map { |role| role&.to_h&.symbolize_keys }
      .compact
  end

  def self.matchable_roles(attribution)
    attribution_roles(attribution).select do |role|
      role[:type].present? && (role[:person_id].present? || role[:organization_id].present?)
    end
  end

  # @param query [Scope] the base scope to filter
  # @param attribution [Hash, ActionController::Parameters]
  # @return [Scope] of all Attributions associated with query that have some
  # data that matches attribution.
  def self.attribution_scope_for(query, attribution)
    attrs = attribution.to_h.symbolize_keys
    scope = Attribution.includes(:roles).where(
      attribution_object_id: query.select(:id),
      attribution_object_type: query.klass.name
    )

    scope = scope.where(license: attrs[:license]) if attrs[:license].present?
    scope = scope.where(copyright_year: attrs[:copyright_year]) if attrs[:copyright_year].present?

    matchable_roles(attrs).each do |role|
      role_type = role[:type]
      next if role_type.blank?

      role_scope = Role.where(role_object_type: 'Attribution', type: role_type)
      if role[:person_id].present?
        role_scope = role_scope.where(person_id: role[:person_id])
      elsif role[:organization_id].present?
        role_scope = role_scope.where(organization_id: role[:organization_id])
      else
        next
      end

      scope = scope.where(id: role_scope.select(:role_object_id))
    end

    scope
  end

  # Assumes 1:1 replacement (enforced by UI):
  # - If replacing license, new_attrs must have a license
  # - If replacing copyright_year, new_attrs must have a copyright_year
  # - If replacing a role, new_attrs must have exactly one role of the same type
  def self.apply_replace_attribution(
    attribution, replace_attribution, new_attribution
  )
    replace_attrs = replace_attribution.to_h.symbolize_keys
    new_attrs = new_attribution.to_h.symbolize_keys

    update_payload = {}
    update_payload[:license] = new_attrs[:license] if new_attrs[:license].present? && replace_attrs[:license].present? && replace_attrs[:license] == attribution.license
    update_payload[:copyright_year] = new_attrs[:copyright_year] if new_attrs[:copyright_year].present? && replace_attrs[:copyright_year].present? && replace_attrs[:copyright_year] == attribution.copyright_year

    replace_roles = matchable_roles(replace_attrs)
    new_roles = matchable_roles(new_attrs)

    roles_to_update, roles_to_delete =
      role_replacement_actions(attribution, replace_roles, new_roles)

    return :noop if update_payload.empty? && roles_to_update.empty? && roles_to_delete.empty?

    Attribution.transaction do
      roles_to_update.each do |item|
        role_update = {}
        if item[:new_role][:person_id].present?
          role_update[:person_id] = item[:new_role][:person_id]
          role_update[:organization_id] = nil
        elsif item[:new_role][:organization_id].present?
          role_update[:organization_id] = item[:new_role][:organization_id]
          role_update[:person_id] = nil
        end
        unless item[:role].update(role_update)
          raise ActiveRecord::Rollback
        end
      end

      roles_to_delete.each do |role|
        unless role.destroy
          raise ActiveRecord::Rollback
        end
      end

      unless update_payload.empty?
        unless attribution.update(update_payload)
          raise ActiveRecord::Rollback
        end
      end
    end

    attribution.errors.any? ? :invalid : :updated
  end

  # Returns [roles_to_update, roles_to_delete] arrays for role replacement.
  # roles_to_update contains { role:, new_role: } hashes for roles to update in
  # place. roles_to_delete contains roles to delete (when "to" role already
  # exists).
  # Raises TaxonWorks::Error if replace_roles and new_roles are mismatched or
  # have duplicates.
  def self.role_replacement_actions(attribution, replace_roles, new_roles)
    if replace_roles.size != new_roles.size
      raise TaxonWorks::Error, "Mismatched role replacement: each 'from' role must have a corresponding 'to' role - from: #{replace_roles.inspect}, to: #{new_roles.inspect}"
    end

    from_keys = replace_roles.map { |r| [r[:type], r[:person_id], r[:organization_id]] }
    if from_keys.size != from_keys.uniq.size
      raise TaxonWorks::Error, "Duplicate 'from' role in replacement request: #{replace_roles.inspect}"
    end

    roles_to_update = []
    roles_to_delete = []

    replace_roles.each_with_index do |replace_role, index|
      new_role = new_roles[index]

      from_role = attribution.roles.find do |role|
        role.type == replace_role[:type] &&
          ((replace_role[:person_id].present? && role.person_id == replace_role[:person_id]) ||
           (replace_role[:organization_id].present? && role.organization_id == replace_role[:organization_id]))
      end

      next unless from_role

      to_role_exists = attribution.roles.any? do |role|
        role.type == new_role[:type] &&
          ((new_role[:person_id].present? && role.person_id == new_role[:person_id]) ||
           (new_role[:organization_id].present? && role.organization_id == new_role[:organization_id]))
      end

      if to_role_exists
        # Target already exists, just delete the "from" role.
        roles_to_delete << from_role
      else
        roles_to_update << { role: from_role, new_role: new_role }
      end
    end

    [roles_to_update, roles_to_delete]
  end

  # Returns a hash with :license and/or :copyright_year set to nil for those
  # that match between attribution and remove_attrs.
  def self.attrs_to_clear(attribution, remove_attrs)
    payload = {}
    payload[:license] = nil if remove_attrs[:license].present? && remove_attrs[:license] == attribution.license
    payload[:copyright_year] = nil if remove_attrs[:copyright_year].present? && remove_attrs[:copyright_year] == attribution.copyright_year
    payload
  end

  # Returns an array of role IDs from attribution that match remove_roles.
  def self.matching_role_ids(attribution, remove_roles)
    return [] unless remove_roles.any?

    ids = []
    attribution.roles.each do |role|
      remove_roles.each do |remove_role|
        next unless role.type == remove_role[:type]
        if remove_role[:person_id].present? && role.person_id == remove_role[:person_id]
          ids << role.id
        elsif remove_role[:organization_id].present? && role.organization_id == remove_role[:organization_id]
          ids << role.id
        end
      end
    end
    ids.uniq
  end

  # Removes those attribution elements from remove_attribution that exist on
  # attribution.
  def self.apply_remove_attribution(attribution, remove_attribution)
    remove_attrs = remove_attribution.to_h.symbolize_keys
    remove_roles = matchable_roles(remove_attrs)

    update_payload = attrs_to_clear(attribution, remove_attrs)
    roles_to_remove = matching_role_ids(attribution, remove_roles)

    return :noop if update_payload.empty? && roles_to_remove.empty?

    final_license = update_payload.key?(:license) ? nil : attribution.license
    final_year = update_payload.key?(:copyright_year) ? nil : attribution.copyright_year
    final_roles_present = if roles_to_remove.any?
      (attribution.roles.size - roles_to_remove.size) > 0
    else
      attribution.roles.any?
    end

    should_destroy = final_license.blank? && final_year.blank? && !final_roles_present

    result = nil

    Attribution.transaction do
      if roles_to_remove.any?
        destroyed_roles = attribution.roles.where(id: roles_to_remove).destroy_all
        # destroy_all fails silently, so check its work.
        unless destroyed_roles.all?(&:destroyed?)
          raise ActiveRecord::Rollback
        end
      end

      if should_destroy
        if attribution.destroy
          result = :destroyed
        else
          raise ActiveRecord::Rollback
        end
      else
        unless update_payload.empty?
          unless attribution.update(update_payload)
            raise ActiveRecord::Rollback
          end
        end
        result = :updated
      end
    end

    result || :invalid
  end

  # This is add, so only add data from new_attribution that will be 'new' in
  # attribution (the not-new case is 'replace').
  def self.apply_add_attribution(attribution, new_attribution)
    attrs = new_attribution.to_h.symbolize_keys
    roles_attributes = attribution_roles(attrs)

    update_payload = {}
    update_payload[:license] = attrs[:license] if attribution.license.blank? && attrs[:license].present?
    update_payload[:copyright_year] = attrs[:copyright_year] if attribution.copyright_year.blank? && attrs[:copyright_year].present?

    if roles_attributes.any?
      existing_roles = attribution.roles.map do |role|
        [role.type, role.person_id, role.organization_id]
      end.to_set

      new_roles = roles_attributes.map do |role|
        role.slice(:type, :person_id, :organization_id).compact
      end

      # Roles are has_many, so we add as long as the new role doesn't already
      # exist.
      unique_roles = new_roles.reject do |role|
        existing_roles.include?([role[:type], role[:person_id], role[:organization_id]])
      end

      if unique_roles.any?
        update_payload[:roles_attributes] = unique_roles
      end
    end

    return :noop if update_payload.empty?

    attribution.update(update_payload)
    attribution.errors.any? ? :invalid : :updated
  end

end
