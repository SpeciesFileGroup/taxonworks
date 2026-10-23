# Sort keys for ::Image, see Queries::Sort::Base.
class Queries::Image::Sort < Queries::Sort::Base
  class << self
    def columns_uncached
      sortable_direct_columns
    end
  end
end
