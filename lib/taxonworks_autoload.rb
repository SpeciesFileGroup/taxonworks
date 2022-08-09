# Work arounds for eager loading issues.
#
# Some models require their subclasses at the end of their definition.
module TaxonWorksAutoload
  # Order matters throughout this block (sigh)

  %w{
    /lib/vendor/**/*.rb
    /lib/analysis/**/*.rb
    /config/routes/api.rb
    /lib/catalog/**/*.rb
  }.each do |path|
    a = Dir[Rails.root.to_s + path].sort
    a.each {|file| require_dependency file }
  end

  require 'dwc_archive'
end
