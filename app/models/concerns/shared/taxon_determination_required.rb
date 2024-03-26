# Shared code for models that must have at least one TaxonDetermination.
#
# !! This require code must come before Shared::BiologicalExtensions !!
#
module Shared::TaxonDeterminationRequired
  extend ActiveSupport::Concern

  included do

    attr_accessor :ignore_taxon_determination_restriction

    before_destroy :ignore_restriction

    def ignore_restriction
      @ignore_taxon_determination_restriction = true
    end
  end

  # @return [True]
  def requires_taxon_determination?
    true
  end

end
