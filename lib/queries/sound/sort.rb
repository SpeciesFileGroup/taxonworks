# Sort keys for ::Sound, see Queries::Sort::Base.
class Queries::Sound::Sort < Queries::Sort::Base
  class << self
    def columns_uncached
      sortable_direct_columns
    end
  end
end
