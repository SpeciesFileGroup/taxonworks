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

  belongs_to :parent_organization, foreign_key: :parent_organization_id, class_name: 'Organization'
  belongs_to :department, foreign_key: :department_id, class_name: 'Organization'
  belongs_to :same_as, foreign_key: :same_as_id, class_name: 'Organization'
  
  belongs_to :area_served, foreign_key: :area_served_id, class_name: 'GeographicArea'

  has_many :roles, dependent: :restrict_with_error, inverse_of: :organization #, before_remove: :set_cached_for_related

  validates_presence_of :name
  validates_uniqueness_of :legal_name, allow_nil: true
  validates :email, format:  {with: User::VALID_EMAIL_REGEX}, allow_nil: true # TODO: unify

  validate :related_not_self
  validate :names_not_same


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
