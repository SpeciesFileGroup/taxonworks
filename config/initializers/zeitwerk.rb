Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect(
    "taxonworks" => "TaxonWorks"
  )
end
