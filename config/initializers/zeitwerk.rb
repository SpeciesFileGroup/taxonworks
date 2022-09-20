Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect(
    "taxonworks" => "TaxonWorks",
    "version" => "VERSION" # Maybe move to earlier place
  )
end
