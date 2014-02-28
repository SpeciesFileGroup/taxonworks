class Otu < ActiveRecord::Base
  include Housekeeping
  include Shared::Identifiable
  include Shared::Citable        # TODO: have to think hard about this vs. using Nico's framework
  include Shared::Notable
  include Shared::DataAttributes
  include Shared::Taggable
  include Shared::AlternateValues

  has_many :contents, inverse_of: :otu
  has_many :taxon_determinations, inverse_of: :otu
  has_many :collection_profiles
  has_many :topics, through: :contents, source: :topic  
end
