# Shared code for classes that are "render" sensu TaxonWorks, i.e. they
# describe how Data is presented (e.g. Compositions), they are not themselves
# Data. Parallels Shared::IsData, but includes only the plumbing needed to
# create, show, and navigate records.
#
# !! This module must in included last !!
#
module Shared::IsRender

  extend ActiveSupport::Concern

  included do
    include Shared::IsData::Annotation
    include Shared::IsData::Scopes
    include Shared::IsData::Navigation
    include Shared::IsData::Metamorphosize
    include Shared::Permissions
  end

  module ClassMethods

    # @return [Boolean]
    def is_community?
      self < Shared::SharedAcrossProjects ? true : false
    end

  end

end
