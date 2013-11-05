

Dir[Rails.root.to_s + '/app/models/nomenclatural_rank/**/*.rb'].sort.each {|file| require file }

Dir[Rails.root.to_s + '/app/models/taxon_name_relationship/**/*.rb'].sort.each {|file| require file }



module TaxonWorks
  require 'activerecord_utilities'
end
