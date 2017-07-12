# Work arounds for eager loading issues.  Do not include in production.
# For eager loading issues see also some related code in models, e.g. protonym.rb


module TaxonWorksAutoload
  # Order matters throughout this block (sigh)

  %w{
      /app/models/nomenclatural_rank/**/*.rb
      /app/models/taxon_name_relationship/**/*.rb
      /app/models/taxon_name_classification/**/*.rb
      /lib/vendor/**/*.rb
      /config/routes/api.rb
  }.each do |path|
    a = Dir[Rails.root.to_s + path].sort
    a.each {|file| require_dependency file } # was .sort
  end

  # handled inline in models at the end of file
  #     /app/models/alternate_value/**/*.rb - 
  #     /app/models/containers/**/*.rb - 

  # %w{Predicate Topic Keyword BiocurationClass BiologicalProperty BiocurationGroup}.each do |cv_class|
  #   file = Rails.root.to_s + '/app/models/' + cv_class.underscore + '.rb'
  #   require_dependency file
  # end

  #  Dir[Rails.root.to_s + '/app/models/controlled_vocabulary_term/**/*.rb'].sort.each {|file| require_dependency file }
end
