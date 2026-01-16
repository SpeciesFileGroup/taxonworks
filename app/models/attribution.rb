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

  def self.attribution_scope_for(query, attribution)
    attrs = attribution.to_h.symbolize_keys
    scope = Attribution.includes(:roles).where(
      attribution_object_id: query.pluck(:id),
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

  def self.apply_replace_attribution(attribution, replace_attribution, new_attribution)
    replace_attrs = replace_attribution.to_h.symbolize_keys
    new_attrs = new_attribution.to_h.symbolize_keys
    replace_roles = matchable_roles(replace_attrs)

    update_payload = {}
    update_payload[:license] = new_attrs[:license] if replace_attrs[:license].present?
    update_payload[:copyright_year] = new_attrs[:copyright_year] if replace_attrs[:copyright_year].present?

    roles_payload = []
    roles_to_remove = []
    if replace_roles.any?
      roles_payload = attribution_roles(new_attrs).map do |role|
        role.slice(
          :id,
          :type,
          :person_id,
          :organization_id,
          :position,
          :person_attributes,
          :_destroy
        ).compact
      end

      attribution.roles.each do |role|
        replace_roles.each do |remove_role|
          next unless role.type == remove_role[:type]
          if remove_role[:person_id].present? && role.person_id == remove_role[:person_id]
            roles_to_remove << role.id
          elsif remove_role[:organization_id].present? && role.organization_id == remove_role[:organization_id]
            roles_to_remove << role.id
          end
        end
      end
      roles_to_remove.uniq!
    end

    return :noop if update_payload.empty? && roles_payload.empty? && roles_to_remove.empty?

    final_license = update_payload.key?(:license) ? update_payload[:license] : attribution.license
    final_year = update_payload.key?(:copyright_year) ? update_payload[:copyright_year] : attribution.copyright_year
    if replace_roles.any?
      final_roles_present =
        (attribution.roles.size - roles_to_remove.size + roles_payload.size) > 0
    else
      final_roles_present = attribution.roles.any?
    end

    if final_license.blank? && final_year.blank? && !final_roles_present
      attribution.destroy
      return :destroyed
    end

    Attribution.transaction do
      attribution.roles.where(id: roles_to_remove).destroy_all if roles_to_remove.any?
      update_payload[:roles_attributes] = roles_payload if roles_payload.any?
      unless update_payload.empty?
        unless attribution.update(update_payload)
          raise ActiveRecord::Rollback
        end
      end
    end

    attribution.errors.any? ? :invalid : :updated
  end

  def self.apply_remove_attribution(attribution, remove_attribution)
    attrs = remove_attribution.to_h.symbolize_keys
    remove_roles = matchable_roles(attrs)

    update_payload = {}
    update_payload[:license] = nil if attrs[:license].present?
    update_payload[:copyright_year] = nil if attrs[:copyright_year].present?

    roles_to_remove = []
    if remove_roles.any?
      attribution.roles.each do |role|
        remove_roles.each do |remove_role|
          next unless role.type == remove_role[:type]
          if remove_role[:person_id].present? && role.person_id == remove_role[:person_id]
            roles_to_remove << role.id
          elsif remove_role[:organization_id].present? && role.organization_id == remove_role[:organization_id]
            roles_to_remove << role.id
          end
        end
      end
      roles_to_remove.uniq!
    end

    final_license = update_payload.key?(:license) ? nil : attribution.license
    final_year = update_payload.key?(:copyright_year) ? nil : attribution.copyright_year
    final_roles_present = if roles_to_remove.any?
      (attribution.roles.size - roles_to_remove.size) > 0
    else
      attribution.roles.any?
    end

    if final_license.blank? && final_year.blank? && !final_roles_present
      attribution.destroy
      return :destroyed
    end

    Attribution.transaction do
      if remove_roles.any?
        attribution.roles.where(id: roles_to_remove).destroy_all if roles_to_remove.any?
      end

      unless update_payload.empty?
        unless attribution.update(update_payload)
          raise ActiveRecord::Rollback
        end
      end
    end

    if attribution.errors.any?
      return :invalid
    end

    update_payload.empty? && roles_to_remove.empty? ? :noop : :updated
  end

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
        [
          role[:type],
          role[:person_id],
          role[:organization_id],
          role.slice(
            :id,
            :type,
            :person_id,
            :organization_id,
            :position,
            :person_attributes,
            :_destroy
          ).compact
        ]
      end

      unique_roles = new_roles.reject do |(role_type, person_id, organization_id, _payload)|
        existing_roles.include?([role_type, person_id, organization_id])
      end

      if unique_roles.any?
        update_payload[:roles_attributes] = unique_roles.map { |entry| entry[3] }
      end
    end

    return :noop if update_payload.empty?

    Attribution.transaction do
      unless attribution.update(update_payload)
        raise ActiveRecord::Rollback
      end
    end

    attribution.errors.any? ? :invalid : :updated
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

end
