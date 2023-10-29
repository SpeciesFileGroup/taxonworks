
# TODO: Permits things like annotation metadata handling.
# Perhaps a more targetted initialization per model would permit
# faster initiationalization, but it might also become more
# explicity dependency wise.
#
Rails.application.reloader.to_prepare do

  # Eager load all base-class ApplicationRecord models
  Dir[Rails.root.join('app/models/*.rb')].each do |model_file|
    require model_file
  end

end
