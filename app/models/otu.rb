class Otu < ActiveRecord::Base

  include Shared::Identifiable
  has_many :specimen_determinations
  has_many :contents
  has_many :otu_contents

end
