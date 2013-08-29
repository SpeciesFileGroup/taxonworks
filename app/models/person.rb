class Person < ActiveRecord::Base

  validates_presence_of :last_name, :type
  before_validation :set_type_if_blank

  has_many(:roles)







  protected
  def set_type_if_blank
    self.type ||= "Anonymous" # if self.type.blank?
  end

end

