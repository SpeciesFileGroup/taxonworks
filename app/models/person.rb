class Person < ActiveRecord::Base

  validates_presence_of :last_name, :type
  before_validation :set_type_if_blank

  has_many(:roles)

  def name 
    [self.first_name, self.suffix, self.last_name, self.postfix].compact.join(" ")
  end

  protected

  def set_type_if_blank
    self.type ||= "Unvetted" 
  end

end

