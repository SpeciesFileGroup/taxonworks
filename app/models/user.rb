# A User is a TaxonWorks user, at present someone who can logon to the private workebench.
#   All Data Models contain created_by_id and updated_by_id that references a User.  
#
# A user may have a number of *attributes* that define roles/subclasses of a sort:
#
# 1) Administrators (User#is_administrator = true).  An administrator can do absolutely everything, in any
# project, and across any project, *except* set User#is_administrator = false.  It is intended that there
# be only 1-2 administrators per instance of TaxonWorks.
#
# 2) Project Administrators (ProjectMember#is_project_administrator). 
# A project administrator can set Project settings and preferences, including the views that a Worker can see.
#
# 3) Superuser. A super_user (code only) is a User that is a project administrator OR administrator.
#
# 4) Worker. A worker is a User that can only see parts of the workbench allowed by a ProjectAdministrator.
#
# Data models in TaxonWorks reference People, who may have roles as Sources (or others), i.e. Users are not "data" and
# not linked directly to People records.
#
# Users must never be shared by real-life humans. 
#
#
# @!attribute name 
#   @return [String]
#   A users name.  Not intended to be a nickname, but this is loosely enforced.  Attribute is 
#   intended to identify a human who owns this account.
#
# @!attribute email 
#   @return [String]
#   The users email, and login. 
#
class User < ActiveRecord::Base

#  include Housekeeping
  include Shared::Notable
  include Shared::DataAttributes


  before_create :set_remember_token

  # TODO: downcase does not work for non-ascii characters which means our
  #       validation for uniqueness will fail ... why?
  # SEE: http://stackoverflow.com/questions/2049502/what-characters-are-allowed-in-email-address
  # SEE: http://unicode-utils.rubyforge.org/

  before_save { self.email = email.to_s.downcase }
  before_validation { self.email = email.to_s.downcase }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true,
            format:           {with: VALID_EMAIL_REGEX},
            uniqueness:       true

  has_secure_password

  validates :password,
            length:       {minimum: 8, :if => :validate_password?},
            :confirmation => {:if => :validate_password?}

  validates :name, presence: true
  validates :name, length: {minimum: 3}, unless: :name_is_empty

  has_many :project_members, dependent: :destroy
  has_many :projects, through: :project_members
  has_many :pinboard_items, dependent: :destroy

  def name_is_empty
    self.name.blank?
  end

  def User.secure_random_token
    SecureRandom.urlsafe_base64
  end

  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def is_superuser?(project = nil)
    is_administrator || is_project_administrator?(project)
  end

  def is_administrator?
    is_administrator.blank? ? false : true
  end

  def is_project_administrator?(project = nil)
    return false if project.nil?
    project.project_members.where(user_id: id).first.is_project_administrator
  end

  def add_page_to_favorites(favourite_route)
    update_attributes(favorite_routes: ([favourite_route] + favorite_routes).uniq[0..19])
    true
  end

  def add_page_to_recent(recent_route)
    case recent_route
      when /^\/$/
      when /hub/
      when /\/autocomplete\?/
      else
        update_attributes(recent_routes: ([recent_route] + recent_routes).uniq[0..9])
    end
    true
  end

  def generate_password_reset_token()
    token                          = User.secure_random_token
    self.password_reset_token      = User.encrypt(token)
    self.password_reset_token_date = DateTime.now
    token
  end

  def password_reset_token_matches?(token)
    self.password_reset_token == User.encrypt(token)
  end

  def pinboard_hash(project_id)
    pinboard_items.where(project_id: project_id).order('pinned_object_type DESC').to_a.group_by { |a| a.pinned_object_type }
  end

  private

  def set_remember_token
    self.remember_token = User.encrypt(User.secure_random_token)
  end

  def validate_password?
    password.present? || password_confirmation.present?
  end

end
