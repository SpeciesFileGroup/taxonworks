module TaxonWorks
<<<<<<< HEAD
  require 'soft_validation'
  Dir[Rails.root.to_s + '/app/models/nomenclatural_rank/**/*.rb'].sort.each {|file| require file }
  Dir[Rails.root.to_s + '/app/models/taxon_name_relationship/**/*.rb'].sort.each {|file| require file }
=======
  require 'activerecord_utilities'
>>>>>>> 2a6d3cdfa18001a136ae2ebbabc92302fd6a9a10
end
