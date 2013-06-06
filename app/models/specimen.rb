class Specimen < ActiveRecord::Base

  include Shared::Identifiable

  has_one :container, through: :container_item
  has_one :container_item
  has_many :specimen_determinations
  has_many :otus, through: :specimen_determinations

  validates_presence_of :total 

end
