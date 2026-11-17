# Helpers and facets for queries against models with a polymorphic,
# position-ordered TaxonDetermination (`as: :taxon_determination_object`,
# see Shared::BiologicalExtensions) - presently CollectionObject and
# FieldOccurrence.
#
module Queries::Concerns::TaxonDetermination

  include Queries::Helpers

  extend ActiveSupport::Concern

  def self.params
    [
      :current_determinations,
      :descendants,
      :otu_id,
      :taxon_name_current_determination,
      :taxon_name_id,
      :validity,
      otu_id: [],
      taxon_name_id: []
    ]
  end

  included do
    # @return [Array, nil]
    #  Otu ids, matches on the TaxonDetermination, see also current_determinations
    attr_accessor :otu_id

    # @return [Array of TaxonName.id, nil]
    #   return all records determined as an Otu that is self or descendant linked
    #   to this TaxonName
    attr_accessor :taxon_name_id

    # @return [Boolean, nil]
    #   nil - exact match on taxon_name_id only (default)
    #   true - also match descendants of taxon_name_id (via taxon_name_hierarchies)
    attr_accessor :descendants

    # @return [Boolean, nil]
    #   nil = Match against only valid ancestors (default)
    #   true = Match against all ancestors, valid or invalid
    #   false = Match against only invalid ancestors
    #   Used only with taxon_name_id
    attr_accessor :validity

    # @return [Boolean, nil]
    #   nil = TaxonDetermination must be .current (default)
    #   true = TaxonDeterminations match regardless of current or historical
    #   false = TaxonDetermination must be .historical
    #   Used only with otu_id, see also taxon_name_current_determination
    attr_accessor :current_determinations

    # @return [Boolean, nil]
    #   nil = TaxonDetermination must be .current (default)
    #   true = TaxonDeterminations match regardless of current or historical
    #   false = TaxonDetermination must be .historical
    #   Used only with taxon_name_id, see also current_determinations
    attr_accessor :taxon_name_current_determination

    # Overrides the attr_accessor reader above - must stay in this `included do`
    # block so it's defined directly on the including class, otherwise the
    # attr_accessor reader (also defined directly on the class) would shadow it.
    def otu_id
      [@otu_id].flatten.compact.uniq
    end

    def taxon_name_id
      [@taxon_name_id].flatten.compact.uniq
    end
  end

  def set_taxon_determination_params(params)
    @current_determinations = boolean_param(params, :current_determinations)
    @descendants = boolean_param(params, :descendants)
    @otu_id = params[:otu_id]
    @taxon_name_current_determination = boolean_param(params, :taxon_name_current_determination)
    @taxon_name_id = params[:taxon_name_id]
    @validity = boolean_param(params, :validity)
  end

  # @return [Arel::Table]
  def taxon_determination_table
    ::TaxonDetermination.arel_table
  end

  # @return [Arel::Table]
  def otu_table
    ::Otu.arel_table
  end

  def otu_id_facet
    return nil if otu_id.empty?

    w = taxon_determination_table[:taxon_determination_object_id].eq(table[:id])
      .and(taxon_determination_table[:otu_id].in(otu_id))
      .and(taxon_determination_table[:taxon_determination_object_type].eq(referenced_klass.base_class.name))

    if current_determinations == true
      # current and historical - no position filter
    elsif current_determinations == false
      w = w.and(taxon_determination_table[:position].gt(1))
    else # nil = current only (default)
      w = w.and(taxon_determination_table[:position].eq(1))
    end

    referenced_klass.where(
      ::TaxonDetermination.where(w).arel.exists
    )
  end

  # TODO: use filter proxy
  def taxon_name_id_facet
    return nil if taxon_name_id.empty?

    q = nil
    z = nil

    if descendants
      h = Arel::Table.new(:taxon_name_hierarchies)
      t = ::TaxonName.arel_table

      q = table.join(taxon_determination_table, Arel::Nodes::InnerJoin).on(
        table[:id].eq(taxon_determination_table[:taxon_determination_object_id])
        .and(taxon_determination_table[:taxon_determination_object_type]).eq(referenced_klass.base_class.name)
      ).join(otu_table, Arel::Nodes::InnerJoin).on(
        taxon_determination_table[:otu_id].eq(otu_table[:id])
      ).join(t, Arel::Nodes::InnerJoin).on(
        otu_table[:taxon_name_id].eq(t[:id])
      ).join(h, Arel::Nodes::InnerJoin).on(
        t[:id].eq(h[:descendant_id])
      )
      z = h[:ancestor_id].in(taxon_name_id)

      if validity == true
        # both valid and invalid - no filter
      elsif validity == false
        z = z.and(t[:cached_valid_taxon_name_id].not_eq(t[:id]))
      else # nil = valid only (default)
        z = z.and(t[:cached_valid_taxon_name_id].eq(t[:id]))
      end

      if taxon_name_current_determination == true
        # current and historical - no position filter
      elsif taxon_name_current_determination == false
        z = z.and(taxon_determination_table[:position].gt(1))
      else # nil = current only (default)
        z = z.and(taxon_determination_table[:position].eq(1))
      end
    else # exact
      q = referenced_klass.joins(taxon_determinations: { otu: :taxon_name })
        .where(otus: { taxon_name_id: })

      if validity == true
        # both valid and invalid - no filter
      elsif validity == false
        q = q.where('taxon_names.cached_valid_taxon_name_id != taxon_names.id')
      else # nil = valid only (default)
        q = q.where('taxon_names.cached_valid_taxon_name_id = taxon_names.id')
      end

      if taxon_name_current_determination == true
        # current and historical - no position filter
      elsif taxon_name_current_determination == false
        q = q.where.not(taxon_determinations: { position: 1 })
      else # nil = current only (default)
        q = q.where(taxon_determinations: { position: 1 })
      end

      return q
    end

    referenced_klass.joins(q.join_sources).where(z).distinct
  end

  def self.merge_clauses
    [
      :otu_id_facet,
      :taxon_name_id_facet,
    ]
  end

end
