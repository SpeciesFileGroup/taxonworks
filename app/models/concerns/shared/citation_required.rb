# Shared code for models that must have at least one Citation.
#
# !! This require code must come before Shared::Citation !!
#
module Shared::CitationRequired
  extend ActiveSupport::Concern

  included do

    attr_accessor :ignore_citation_restriction

    before_destroy :ignore_restriction

    def ignore_restriction
      @ignore_citation_restriction = true
    end
  end

  # @return [True]
  def requires_citation?
    true
  end

end
