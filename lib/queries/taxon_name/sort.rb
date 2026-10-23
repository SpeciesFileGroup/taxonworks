# Sort keys for ::TaxonName, see Queries::Sort::Base.
class Queries::TaxonName::Sort < Queries::Sort::Base
  class << self
    def columns_uncached
      cols = sortable_direct_columns

      # Existing wire-format keys that don't match the underlying column name.
      cols['cached_html'] = direct(:cached)
      cols['original_combination'] = direct(:cached_original_combination)
      cols['rank'] = direct(:rank_class)

      # cached_valid_taxon_name_id points to self when the name is valid, in
      # which case the frontend shows the Valid name column as blank. Match
      # that in SQL by nulling out the self-referential case, so valid rows
      # all sort to the end (NULLS LAST). The join itself is a plain
      # belongs_to (:valid_taxon_name); the business rule on top isn't
      # expressible via association(), so this stays custom.
      cols['valid_name'] = ->(q, dir) {
        q
          .joins('LEFT JOIN taxon_names AS sort_valid_name ON sort_valid_name.id = taxon_names.cached_valid_taxon_name_id')
          .order(Arel.sql(
            "CASE WHEN sort_valid_name.id = taxon_names.id THEN NULL ELSE sort_valid_name.cached END " \
            "#{dir == :desc ? 'DESC' : 'ASC'} NULLS LAST"
          ))
      }

      cols['parent'] = association(:parent, :cached)

      # Formerly the TaxonName filter's own `sort` modes.
      cols['alphabetical'] = direct(:cached)

      # Higher names before lower: depth below the root, then name.
      cols['classification'] = ->(q, dir) {
        q
          .joins(<<~SQL.squish)
            LEFT JOIN LATERAL (
              SELECT MAX(tnh.generations) AS depth
              FROM taxon_name_hierarchies tnh
              WHERE tnh.descendant_id = taxon_names.id
            ) AS sort_classification ON true
          SQL
          .order(Arel.sql("sort_classification.depth #{sort_direction(dir)} NULLS LAST, taxon_names.cached ASC NULLS LAST"))
      }

      cols
    end
  end
end
