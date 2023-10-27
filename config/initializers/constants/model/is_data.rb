# Used as a white list when you need to safely constantize.
DATA_MODELS = ApplicationEnumeration.data_models.inject({}){|hsh, k| hsh.merge!(k.name => k)}.freeze
