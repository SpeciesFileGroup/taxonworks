# Work arounds for eager loading issues.  Do not include in production.
# For eager loading issues see also some related code in models, e.g. protonym.rb


module TaxonWorksAutoload
  if Rails.env == 'test' || Rails.env == 'development' 
    # Order matters throughout this block (sigh)
    %w{
      /app/models/taxon_name
      /app/models/protonym
      /app/models/nomenclatural_rank/**/*.rb
      /app/models/taxon_name_relationship/**/*.rb
      /app/models/taxon_name_classification/**/*.rb
      /app/models/container/**/*.rb
      /app/models/alternate_value/**/*.rb
    }.each do |path|
      Dir[Rails.root.to_s + path].sort.each {|file| require_dependency file } # was .sort
    end

    %w{Predicate Topic Keyword BiocurationClass BiologicalProperty BiocurationGroup}.each do |cv_class|
      file = Rails.root.to_s + '/app/models/' + cv_class.underscore + '.rb'
      require_dependency file
    end

    Dir[Rails.root.to_s + '/app/models/controlled_vocabulary_term/**/*.rb'].sort.each {|file| require_dependency file }
  end
end
