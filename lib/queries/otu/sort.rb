# Sort keys for ::Otu, see Queries::Sort::Base.
#
# `otu`/`otu_taxonomy_*` are a display-name COALESCE and closure-tree
# taxonomy walks (see sort_by_display_name below and
# sort_by_object_taxonomy in Queries::Sort::ObjectOtu) -- neither is
# expressible via association(), so they stay hand-written.
class Queries::Otu::Sort < Queries::Sort::Base
  class << self
    def columns_uncached
      cols = sortable_direct_columns

      cols['otu'] = sort_by_display_name
      cols['otu_taxonomy_order'] = sort_by_object_taxonomy(
        rank: 'Order', id_expr: 'otus.id', type_expr: "'Otu'", alias_prefix: 'sort_otu_taxonomy_order'
      )
      cols['otu_taxonomy_family'] = sort_by_object_taxonomy(
        rank: 'Family', id_expr: 'otus.id', type_expr: "'Otu'", alias_prefix: 'sort_otu_taxonomy_family'
      )
      cols['otu_taxonomy_genus'] = sort_by_object_taxonomy(
        rank: 'Genus', id_expr: 'otus.id', type_expr: "'Otu'", alias_prefix: 'sort_otu_taxonomy_genus'
      )

      cols
    end

    # OTU's display value (otu_tag) is essentially the taxon_name.cached
    # falling back to otu.name. Use a scalar subquery so we don't add a
    # second `taxon_names` alias to the outer FROM -- callers like the
    # OTU controller chain `.order(:cached, 'otus.name')` after `.all`,
    # and having taxon_names in the FROM twice makes bare `cached`
    # ambiguous.
    def sort_by_display_name
      ->(q, dir) {
        q.order(Arel.sql(<<~SQL.squish))
          COALESCE(
            (SELECT tn.cached FROM taxon_names tn WHERE tn.id = otus.taxon_name_id),
            otus.name
          ) #{dir == :desc ? 'DESC' : 'ASC'} NULLS LAST
        SQL
      }
    end
  end
end
