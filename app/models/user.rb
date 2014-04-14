class User < ActiveRecord::Base

  before_create :set_remember_token

  # TODO: downcase does not work for non-ascii characters which means our
  #       validation for uniqueness will fail ... why?
  # SEE: http://stackoverflow.com/questions/2049502/what-characters-are-allowed-in-email-address
  # SEE: http://unicode-utils.rubyforge.org/
  before_save { self.email = email.to_s.downcase }
  before_validation { self.email = email.to_s.downcase }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence:   true,
                    format:     { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: true }
  has_secure_password
  validates :password, length: { minimum: 8 }

  has_many :project_members
  has_many :projects, through: :project_members

  def User.secure_random_token
    SecureRandom.urlsafe_base64
  end

  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  private

  def set_remember_token
    self.remember_token = User.encrypt(User.secure_random_token)
  end
end
