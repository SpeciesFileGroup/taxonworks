# Used as a white list when you need to safely constantize.


Rails.application.reloader.to_prepare do

  DATA_MODELS = ApplicationEnumeration.data_models.inject({}){|hsh, k| hsh.merge!(k.name => k)}.freeze

end
