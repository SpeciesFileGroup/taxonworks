class User < ActiveRecord::Base

  # TODO: downcase does not work for non-ascii characters which means our
  #       validation for uniqueness will fail ... why?
  # SEE: http://stackoverflow.com/questions/2049502/what-characters-are-allowed-in-email-address
  # SEE: http://unicode-utils.rubyforge.org/

  #  include Housekeeping::Users

  before_validation { self.email = email.downcase }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence:   true,
    format:     { with: VALID_EMAIL_REGEX } ,
    uniqueness: { case_sensitive: true }
  has_secure_password
  validates :password, length: { minimum: 8 }

end
