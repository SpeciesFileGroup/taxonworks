class Otu < ActiveRecord::Base
  include Shared::Identifiable
  has_many :specimen_determinations
end
