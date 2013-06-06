class Identifier < ActiveRecord::Base

  belongs_to :identifiable, :polymorphic => :true

  validates_presence_of :identifier, :identifiable_id, :identifiable_type, :type
end
