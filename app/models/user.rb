# A User is a TaxonWorks user, at present someone who can logon to the private workebench.
#
# All Data Models contain created_by_id and updated_by_id that references a User.  
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
# 3) Superuser. A super_user (code only) is a User that is a profromct administrator OR administrator.
#
# 4) Worker. A worker is a User that can only see parts of the workbench allowed by a ProjectAdministrator.
#
# Data models in TaxonWorks reference People, who may have roles as Sources (or others), i.e. Users are not "data" and
# not linked directly to People records.
#
# Users must never be shared by real-life humans.
#
# @!attribute email
#   @return [String]
#   the users email, and login.
#
# @!attribute password_digest
#   @return [String]
#   @todo
#
# @!attribute remember_token
#   @return [String]
#   @todo
#
# @!attribute is_administrator
#   @return [Boolean]
#   @todo
#
# @!attribute favorite_routes
#   @return [String]
#   @todo Is return data type correct?
#
# @!attribute password_reset_token
#   @return [String]
#   @todo
#
# @!attribute password_reset_token_date
#   @return [DateTime]
#   @todo Is return data type correct?
#
# @!attribute name
#   @return [String]
#   a users name: Not intended to be a nickname, but this is loosely enforced. Attribute is intended to identify a human who owns this account.
#
# @!attribute current_sign_in_at
#   @return [DateTime]
#   @todo Is return data type correct?
#
# @!attribute last_sign_in_at
#   @return [DateTime]
#   @todo Is return data type correct?
#
# @!attribute current_sign_in_ip
#   @return [String]
#   @todo
#
# @!attribute last_sign_in_ip
#   @return [String]
#   @todo
#
# @!attribute current_sign_in_ip
#   @return [String]
#   @todo
#
# @!attribute hub_tab_order
#   @return [String]
#   @todo
#
# @!attribute api_access_token
#   @return [String]
#   @todo
#
# @!attribute is_flagged_for_password_reset
#   @return [Boolean]
#   @todo
#
# @!attribute footprints
#   @return [Hash]
#   @todo
#
# @!attribute sign_in_count
#   @return [Integer]
#   @todo
#
# @!attribute self_created [r]
#   @return [true, false]
#   Only used for when .new_record? is true. If true assigns creator and updater as self.
#   @todo this attribute left over; delete?
#
class User < ActiveRecord::Base
  
  include Housekeeping::Users
  include Shared::DataAttributes
  include Shared::Notable
  include Shared::Taggable
  include Shared::RandomTokenFields[:password_reset]
  has_secure_password

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  attr_accessor :self_created

  before_create :set_remember_token
  before_create { self.hub_tab_order = DEFAULT_HUB_TAB_ORDER }

  # @todo downcase does not work for non-ascii characters which means our validation for uniqueness will fail ... why?
  # @see http://stackoverflow.com/questions/2049502/what-characters-are-allowed-in-email-address
  # @see http://unicode-utils.rubyforge.org/
  before_validation { self.email = email.to_s.downcase }
  before_save { self.email = email.to_s.downcase }
  after_save :configure_self_created,  if: "self.self_created"

  validates :email, presence: true,
            format: {with: VALID_EMAIL_REGEX},
            uniqueness: true

  validates :password,
            length: {minimum: 8, :if => :validate_password?},
            :confirmation => {:if => :validate_password?}

  validates :name, presence: true
  validates :name, length: {minimum: 2}, unless: 'self.name.blank?'

  has_many :project_members, dependent: :destroy
  has_many :projects, through: :project_members
  has_many :pinboard_items, dependent: :destroy

  def self.not_in_project(project_id)
    ids =   ProjectMember.where(project_id: project_id).pluck(:user_id) 
    return where(false) if ids.empty?

    User.where( User.arel_table[:id].not_eq_all( ids ))
  end

  def User.secure_random_token
    SecureRandom.urlsafe_base64
  end

  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  # @return [true, false]
  # true if user is_administrator or is_project_administrator
  def is_superuser?(project = nil)
    is_administrator || is_project_administrator?(project)
  end

  # @return [true, false]
  # true if is_administrator = true
  def is_administrator?
    is_administrator.blank? ? false : true
  end

  # @return [true, false]
  # true if user is_project_administrator for the project passed
  # @param project [Project]
  def is_project_administrator?(project = nil)
    return false if project.nil?
    project.project_members.where(user_id: id).first.is_project_administrator
  end

  def add_page_to_favorites(favorite_route)
    new_routes = ([favorite_route] + favorite_routes.clone).uniq[0..19].sort
    update_column(:favorite_routes, new_routes )
    true
  end

  def remove_page_from_favorites(favorite_route)
    new_routes = favorite_routes.clone
    new_routes.delete(favorite_route)
    update_column(:favorite_routes, new_routes )
  end

  def add_recently_visited_to_footprint(recent_route, recent_object = nil)
    case recent_route
    when /\A\/\Z/ # the root path '/'
    when /\A\/hub/ # any path which starts with '/hub'
    when /\/autocomplete\?/ # any path used for AJAX autocomplete
    else
 
      fp = footprints.dup 
      fp['recently_visited'] ||= [] 

      attrs = { recent_route => {}  }
      if !recent_object.nil?
        attrs[recent_route].merge!(object_type: recent_object.class.to_s, object_id: recent_object.id)
      end

      fp['recently_visited'].unshift(attrs)
      fp['recently_visited'] = fp['recently_visited'].uniq{|a| a.keys}[0..19]

      self.footprints_will_change!  # if this isn't thrown weird caching happens !
      self.update_column(:footprints, fp)
    end

    true
  end

  def pinboard_hash(project_id)
    pinboard_items.where(project_id: project_id).order('pinned_object_type DESC').to_a.group_by { |a| a.pinned_object_type }
  end

  def total_objects(klass) # klass_name is a string, need .constantize in next line
    klass.where(creator: self).count
  end

  def total_objects2(klass_string)
    self.send("created_#{klass_string}").count #klass.where(creator:self).count
  end

  # @return [Hash]
  # 
  # @user.get_class_created_updated # => { "projects" => {created: 10, first_created: datetime, updated: 10, last_updated: datetime} }
  def get_class_created_updated
    Rails.application.eager_load! if Rails.env.development?
    data = {}

    User.reflect_on_all_associations(:has_many).each do |r|
      key = nil
      puts r.name.to_s
      if r.name.to_s =~ /created_/
        # puts "after created"
        key = :created
      elsif r.name.to_s =~ /updated_/
        # puts "after updated"
        key = :updated
      end

      if key
        n = r.klass.name.underscore.humanize.pluralize
        count = self.send(r.name).count

        if data[n]
          data[n].merge!(key => count)
        else
          data.merge!(n => {key => count})
        end

        if count == 0
          data[n].merge!(:first_created => 'n/a')
          data[n].merge!(:last_updated => 'n/a')
        else
          data[n].merge!(:first_created => self.send(r.name).limit(1).order(created_at: :asc).first.created_at)
          data[n].merge!(:last_updated => self.send(r.name).limit(1).order(updated_at: :desc).first.updated_at)
       end
      end
    end
    data
  end
  
  def generate_api_access_token
    self.api_access_token = RandomToken.generate
  end
  
  def require_password_presence
    @require_password_presence = true
  end

  private

  def set_remember_token
    self.remember_token = User.encrypt(User.secure_random_token)
  end

  def validate_password?
    password.present? || password_confirmation.present? || @require_password_presence
  end

  def configure_self_created
    if !self.new_record? && self.creator.nil? && self.updater.nil?
      self.update_columns(created_by_id: self.id, updated_by_id: self.id) # !?
    end
  end

end
