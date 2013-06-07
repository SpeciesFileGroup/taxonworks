class Specimen < ActiveRecord::Base
  include Shared::Identifiable
  include Shared::Containable

  has_many :specimen_determinations
  has_many :otus, through: :specimen_determinations

  validates_presence_of :total 
  validate :value_of_total

  protected

  def value_of_total 
    errors.add(:total, "total must be nil") if !self.total.nil?
  end

end
