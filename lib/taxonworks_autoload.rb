# Work arounds for eager loading issues.
#
# !! Do not include in production. !!
#
# Some models require their subclasses at the end of their definition.
module TaxonWorksAutoload
  # Order matters throughout this block (sigh)
  %w{
    /lib/vendor/**/*.rb
    /config/routes/api.rb
  }.each do |path|
    a = Dir[Rails.root.to_s + path].sort
    a.each {|file| require_dependency file } # was .sort
  end

end
