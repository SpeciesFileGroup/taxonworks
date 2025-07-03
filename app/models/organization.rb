# Organization attributes follow https://schema.org/Organization, with only housekeeping exceptions.
#
# @!attribute name
#   @return [String]
#
#  @!attribute alternate_name
#
#  @!attribute description
#
#  @!attribute disambiguating_description
#
#  @!attribute same_as_id
#    @return [Organization, nil]
#
#  @!attribute address
#
#  @!attribute email
#
#  @!attribute telephone
#
#  @!attribute duns
#
#  @!attribute global_location_number
#
#  @!attribute legal_name
#
#  @!attribute area_served_id
#    @return [GeographicArea, nil]
#
#  @!attribute department_id
#    @return [Organization, nil]
#
#  @!attribute parent_organization_id
#    @return [Organization, nil]
#
class Organization < ApplicationRecord
  include Housekeeping::Users
  include Housekeeping::Timestamps
  include Shared::Notes
  include Shared::Identifiers
  include Shared::SharedAcrossProjects
  include Shared::IsData

  belongs_to :parent_organization, class_name: 'Organization'
  belongs_to :department, class_name: 'Organization'
  belongs_to :same_as, class_name: 'Organization'

  belongs_to :area_served, class_name: 'GeographicArea'

  has_many :roles, dependent: :restrict_with_error, inverse_of: :organization #, before_remove: :set_cached_for_related

  has_many :author_roles, class_name: 'SourceAuthor', dependent: :restrict_with_error, inverse_of: :organization #, before_remove: :set_cached_for_related
  has_many :editor_roles, class_name: 'SourceEditor', dependent: :restrict_with_error, inverse_of: :organization
  has_many :source_roles, class_name: 'SourceSource', dependent: :restrict_with_error, inverse_of: :organization

  has_many :collector_roles, class_name: 'Collector', dependent: :restrict_with_error, inverse_of: :organization
  has_many :determiner_roles, class_name: 'Determiner', dependent: :restrict_with_error, inverse_of: :organization
  has_many :taxon_name_author_roles, class_name: 'TaxonNameAuthor', dependent: :restrict_with_error, inverse_of: :organization
  has_many :georeferencer_roles, class_name: 'Georeferencer', dependent: :restrict_with_error, inverse_of: :organization

  has_many :authored_sources, class_name: 'Source::Bibtex', through: :author_roles, source: :role_object, source_type: 'Source', inverse_of: :authors
  has_many :edited_sources, class_name: 'Source::Bibtex', through: :editor_roles, source: :role_object, source_type: 'Source', inverse_of: :editors
  has_many :human_sources, class_name: 'Source::Bibtex', through: :source_roles, source: :role_object, source_type: 'Source', inverse_of: :people
  has_many :authored_taxon_names, through: :taxon_name_author_roles, source: :role_object, source_type: 'TaxonName', class_name: 'Protonym', inverse_of: :taxon_name_authors
  has_many :collecting_events, through: :collector_roles, source: :role_object, source_type: 'CollectingEvent', inverse_of: :collectors
  has_many :georeferences, through: :georeferencer_roles, source: :role_object, source_type: 'Georeference', inverse_of: :georeference_authors
  has_many :taxon_determinations, through: :determiner_roles, source: :role_object, source_type: 'TaxonDetermination', inverse_of: :determiners

  validates_presence_of :name
  validates_uniqueness_of :legal_name, allow_nil: true
  validates :email, format:  {with: User::VALID_EMAIL_REGEX}, allow_nil: true # TODO: unify

  validate :related_not_self
  validate :names_not_same

  # @param role_type [String] one of the Role types
  # @return [Scope]
  #    the max 10 most recently used (1 week, could parameterize) organizations
  def self.used_recently(user_id, role_type = 'AttributionOwner')
    t = Role.arel_table
    p = Organization.arel_table

    # i is a select manager
    i = t.project(t['organization_id'], t['type'], t['updated_at']).from(t)
      .where(t['updated_at'].gt(1.week.ago))
      .where(t['updated_by_id'].eq(user_id))
      .where(t['type'].eq(role_type))
      .order(t['updated_at'].desc)

    # z is a table alias
    z = i.as('recent_t')

    Organization.joins(
      Arel::Nodes::InnerJoin.new(z, Arel::Nodes::On.new(z['organization_id'].eq(p['id'])))
    ).pluck(:organization_id).uniq
  end

  # @params Role [String] one the available roles
  # @return [Hash] Organizations optimized for user selection
  def self.select_optimized(user_id, project_id, role_type = 'AttributionOwner')
    r = used_recently(user_id, role_type)
    h = {
      quick: [],
      pinboard: Organization.pinned_by(user_id).where(pinboard_items: {project_id:}).to_a,
      recent: []
    }

    if r.empty?
      h[:quick] = Organization.pinned_by(user_id).pinboard_inserted.where(pinboard_items: {project_id:}).to_a
    else
      h[:recent] = Organization.where('"organizations"."id" IN (?)', r.first(10) ).to_a
      h[:quick] = (
        Organization.pinned_by(user_id).pinboard_inserted.where(pinboard_items: {project_id:}).to_a +
        Organization.where('"organizations"."id" IN (?)', r.first(4) ).to_a
      ).uniq
    end
    h
  end

  protected

  def names_not_same
    errors.add(:name, 'is same as alternate name') if name == alternate_name
  end


  def related_not_self
    [:same_as_id, :department_id, :parent_organization_id].each do |a|
      b = send(a)
      errors.add(a, 'can not be self') if b && id == b
    end
  end

end
