class Namespace < ActiveRecord::Base

  validates_presence_of :name, :short_name
end
