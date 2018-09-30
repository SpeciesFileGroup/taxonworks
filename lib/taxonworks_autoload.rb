# Work arounds for eager loading issues.  Do not include in production.
# For eager loading issues see also some related code in models, e.g. protonym.rb
#
#
# Some models require their subclasses at the end of their definition.
module TaxonWorksAutoload
  # Order matters throughout this block (sigh)
  #
  #
# /app/models/nomenclatural_rank/**/*.rb
# /app/models/taxon_name_relationship/**/*.rb
# /app/models/taxon_name_classification/**/*.rb


  %w{
    /lib/vendor/**/*.rb
    /config/routes/api.rb
  }.each do |path|
    a = Dir[Rails.root.to_s + path].sort
    a.each {|file| require_dependency file } # was .sort
  end

end
