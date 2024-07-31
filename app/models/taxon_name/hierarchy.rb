# Methods faciliating use of `parent_id`, nomenclature ranks, ancestors and descendants
#
# TODO: consider use in refactoring full_name_hash
#
module TaxonName::Hierarchy
  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods

    # Return summaries of TaxonName with their requested ranks/names
    # @return Array of TaxonName (not a relation!)
    # @param taxon_name_scope TaxonName::ActiveRecordRelation
    def ranked_taxon_names(taxon_name_scope: TaxonName.none, ranks: ['order', 'family', 'genus', 'species'])
      TaxonName.find_by_sql(
        taxon_name_ancestors_sql(taxon_name_scope:, ranks:)
      )
    end

    # A SQL string that builds a crosstab query, selecting names at the requested
    # ranks into columns, i.e. summarizing ranks in a single row.
    # 
    # The `unnest` was critical in getting this correct, as was distinct, and ordering.
    # 
    # @return String
    # @param taxon_name_scope TaxonName::ActiveRecordRelation
    #   required
    def taxon_name_ancestors_sql(taxon_name_scope: TaxonName.none, ranks: ['order', 'family', 'genus', 'species'])
      ranks = RANKS_BY_NAME.keys if ranks.blank?

      target_ranks = []

      # Note that we need to single quote the first query in the crosstab,
      # thuse the $$ and other quote weirdness

      # !!! scoping query *must* be distinct results, and without order
      s = "SELECT * from crosstab( 'WITH tnq AS (" + taxon_name_scope.unscope(:select, :order).select(:id).all.distinct.to_sql.gsub(/'/,"''") + 
        ' ) SELECT h.descendant_id id, CASE '

      ord = []

      # translate `rank_class` to common name, 
      # works across nomenclature codes, could be optimized
      # to target a specific code at some point
      ranks.each_with_index do |r, i|
        l = RANKS_BY_NAME[r].collect{ |x| "''#{x}''" }
        target_ranks += l  
        ord.push "\n WHEN rank_class IN (#{ l.join(', ') }) THEN ''#{r}'' "
      end

      s << ord.join("\n ")
      s << 'ELSE null END cat, t.name value FROM taxon_names t ' +  
        "JOIN taxon_name_hierarchies h on t.id = h.ancestor_id 
         JOIN tnq as tnq1 on tnq1.id = h.descendant_id
         WHERE 
           t.rank_class IN (#{target_ranks.join(', ')}) 
         AND t.name != ''Root'' " +
      "GROUP BY 1,2,3',
       $$SELECT unnest('{#{ranks.join(', ')}}'::character varying[])$$) 
       AS ct(id integer, " + ranks.collect{|r| "\"#{r}\" character varying"}.join(', ') + ')'
    end

    # @param otu_scope Otu::ActiveRecordRelation
    #    distinct, no order, no select
    # @return Array of Objects
    #     [ { "id" => 926908,
    #        "name" => "Diestrammena (Atachycines) horazumi",
    #        "taxon_name_id" => 946156,
    #        "order" => "Orthoptera",
    #        "family" => "Rhaphidophoridae",
    #        "genus" => "Atachycines",
    #        "species" => "apicalis" } ] 
    # 
    #  Use `.attributes to directly return Hash
    #  
    # A bit of a hybrid method, might also fit as an Otu class method
    def ranked_otus(otu_scope: Otu.none, ranks: ['order', 'family', 'genus', 'species'])
      return Otu.none if ranks.blank? || otu_scope.blank?

      tns = ::Queries::TaxonName::Filter.new({})
      tns.otu_query = otu_scope.unscope(:order).unscope(:select)

      s = 'WITH tn_anc AS (' + taxon_name_ancestors_sql(taxon_name_scope: tns.all, ranks: ) + ') ' +
        ::Otu.select("otus.id, otus.name, otus.taxon_name_id, #{ranks.collect{|r| "tn_anc1.#{r}"}.join(', ')}").joins('JOIN tn_anc as tn_anc1 ON otus.taxon_name_id = tn_anc1.id')
        .to_sql

      ::Otu.find_by_sql(s)
    end

  end
end

