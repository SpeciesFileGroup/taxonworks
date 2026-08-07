Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect(
    "taxonworks" => "TaxonWorks",
    "version" => "VERSION" # Maybe move to earlier place
  )
end


# Surpress the 'already initialized constant' coming from closure_tree
# See https://github.com/ClosureTree/closure_tree/issues/362.
unless Rails.application.config.cache_classes

  Rails.autoloaders.main.on_unload('TaxonName') do
    Object.send(:remove_const, 'TaxonNameHierarchy')
  end

  Rails.autoloaders.main.on_unload('ContainerItem') do
    Object.send(:remove_const, 'ContainerItemHierarchy')
  end

  Rails.autoloaders.main.on_unload('Lead') do
    Object.send(:remove_const, 'LeadHierarchy')
  end

  Rails.autoloaders.main.on_unload('GeographicArea') do
    Object.send(:remove_const, 'GeographicAreaHierarchy')
  end

end


