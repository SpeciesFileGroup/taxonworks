class Otu < ActiveRecord::Base

  include Housekeeping
  include Shared::Identifiable
  # include Shared::Citable        # TODO: have to think hard about this vs. using Nico's framework
  include Shared::Notable

  has_many :taxon_determinations

  has_many :contents
  has_many :otu_contents
  has_many :text_content, class_name: 'OtuContent::Text'
  has_many :topics,  through: :otu_content_texts, source: :topic  

end
