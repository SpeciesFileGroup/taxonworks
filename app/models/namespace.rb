class Namespace < ActiveRecord::Base
  include Housekeeping::Users
  validates_presence_of :name, :short_name
  validates_uniqueness_of :name, :short_name

  has_many :identifiers
end
