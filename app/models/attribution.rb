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

  def self.batch_by_filter_scope(filter_query: nil, params: nil, mode: :add, async_cutoff: 300, project_id: nil, user_id: nil)
    r = ::BatchResponse.new(
      preview: false,
      method: 'Attribution batch_by_filter_scope',
    )

    if filter_query.nil?
      r.errors['scoping filter not provided'] = 1
      return r
    end

    b = ::Queries::Query::Filter.instantiated_base_filter(filter_query)
    q = b.all(true)

    fq = ::Queries::Query::Filter.base_query_to_h(filter_query)

    r.klass =  b.referenced_klass.name

    if b.only_project?
      r.total_attempted = 0
      r.errors['can not update records without at least one filter parameter'] = 1
      return r
    else
      c = q.count
      async = c > async_cutoff ? true : false

      r.total_attempted = c
      r.async = async
    end

    case mode.to_sym
    when :add
      if async
        AttributionBatchJob.perform_later(
          filter_query: fq,
          params:,
          mode: :add,
          project_id:,
          user_id:,
        )
      else
        attribution_object_type = b.referenced_klass.name
        q.find_each do |o|
          o_params = params.merge({
            attribution_object_id: o.id,
            attribution_object_type:
          })
          o = Attribution.create(o_params)

          if o.valid?
            r.updated.push o.id
          else
            r.not_updated.push nil # no id to add
          end
        end
      end

    # when :remove
    #   # Just delete, async or not
    #   Attribution
    #     .where(
    #       attribution_object_id: q.pluck(:id),
    #       attribution_object_type: b.referenced_klass.name
    #     ).delete_all
    end

    return r.to_json
  end

  protected

  def some_roles_present
    ATTRIBUTION_ROLES.each do |r|
      return true if send("#{r}_roles".to_sym).any?
    end

    if self.roles.any?
      self.roles.each do |r|
        return true if r.type.present? && r.person_id.present?
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
