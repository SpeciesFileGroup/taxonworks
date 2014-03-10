module TaxonWorks
  Dir[Rails.root.to_s + '/app/models/nomenclatural_rank/**/*.rb'].sort.each {|file| require file }
  Dir[Rails.root.to_s + '/app/models/taxon_name_relationship/**/*.rb'].sort.each {|file| require file }
  Dir[Rails.root.to_s + '/app/models/taxon_name_classification/**/*.rb'].sort.each {|file| require file }
  Dir[Rails.root.to_s + '/app/models/container/**/*.rb'].sort.each {|file| require file }
  require 'soft_validation'
  require 'activerecord_utilities'
  require 'squeel'

  # TODO: Move this out of here before production
  # paperclip requires information on where ImageMagick is installed.
  Paperclip.options[:command_path] = "/usr/local/bin/"

end
