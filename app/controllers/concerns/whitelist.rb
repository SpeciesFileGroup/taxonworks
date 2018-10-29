module Whitelist
  extend ActiveSupport::Concern

  # @param klass_name [String] a model name inheriting from IsData
  def whitelist_constantize(klass_name)
    # if Rails.env.development?
    #   ApplicationEnumeration.data_models.inject({}){|hsh, k| hsh.merge!(k.name => k)}.fetch(klass_name)
    # elsif Rails.env.production?
      ::DATA_MODELS.fetch(klass_name)
    # else
    #   raise TaxonWorks::Error, 'whitelist attempted in unknown environment'
    # end
  end

end
