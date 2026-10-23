# Sort keys for ::Source, see Queries::Sort::Base.
class Queries::Source::Sort < Queries::Sort::Base
  class << self
    def columns_uncached
      cols = sortable_direct_columns

      # `belongs_to :serial` is only declared on Source::Bibtex.
      cols['serial'] = association(:serial, :name, on: ::Source::Bibtex)

      cols
    end
  end
end
