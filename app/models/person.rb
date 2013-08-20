class Person < ActiveRecord::Base

  validates_presence_of :last_name, :type
  before_validation :set_type_if_blank

  protected
  def set_type_if_blank
    self.type ||= "Anonymous" # if self.type.blank?
  end

  end

