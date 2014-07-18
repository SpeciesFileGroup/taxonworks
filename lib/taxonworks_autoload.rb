# Work arounds for eager loading issues.  Do not include in production.
module TaxonWorksAutoload
  if Rails.env == 'test' || Rails.env == 'development' 
    Dir[Rails.root.to_s + '/app/models/taxon_name'].sort.each {|file| require file }
    Dir[Rails.root.to_s + '/app/models/protonym'].sort.each {|file| require file }
    Dir[Rails.root.to_s + '/app/models/nomenclatural_rank/**/*.rb'].sort.each {|file| require file }
    Dir[Rails.root.to_s + '/app/models/taxon_name_relationship/**/*.rb'].sort.each {|file| require file }
    Dir[Rails.root.to_s + '/app/models/taxon_name_classification/**/*.rb'].sort.each {|file| require file }
    Dir[Rails.root.to_s + '/app/models/container/**/*.rb'].sort.each {|file| require file }
    Dir[Rails.root.to_s + '/app/models/alternate_value/**/*.rb'].sort.each {|file| require file }

    %w{Predicate Topic Keyword BiocurationClass BiologicalProperty BiocurationGroup}.each do |cv_class|
      file = Rails.root.to_s + '/app/models/' + cv_class.underscore + '.rb'
      require_dependency file
    end

    Dir[Rails.root.to_s + '/app/models/controlled_vocabulary_term/**/*.rb'].sort.each {|file| require file }
  end
end
