# Paper style comprehansive checklist

class Catalog::Nomenclature::PaperCatalog < Catalog::Nomenclature

  ##### FILTER PARAMETERS #####

  # @!classification_scope
  #   @return [String]
  # Higher level taxon to include all descendants
  attr_accessor :classification_scope

  # @!project_id
  #   @return [String]
  # Required attribute to build the key
  attr_accessor :project_id

  # @!rank_filter
  #   @return [String or null]
  # Optional attribute. Restrict output to particular ranks "rank_filter=genus|species|subspecies". Returns all ranks if values is nil
  attr_accessor :rank_filter

  # @!otu_filter
  #   @return [String or null]
  # Optional attribute. Restrict output to particular otus_ids "otu_filter=3|5|15".
  attr_accessor :otu_filter

  # @!taxon_name_filter
  #   @return [String or null]
  # Optional attribute. Restrict output to particular taxon_name_ids "otu_filter=3|5|15".
  attr_accessor :taxon_name_filter

  # @!accepted_only
  #   @return [String or null]
  # Optional attribute. Restrict output to valid_names "accepted_only=true"
  attr_accessor :accepted_only

  # @!type_information
  #   @return [String or null]
  # Optional attribute. Add type information "type=true"
  attr_accessor :type_information

  # @!distribution
  #   @return [String or null]
  # Optional attribute to add distribution "distribution=true"
  attr_accessor :distribution

  # @!otu_contents
  #   @return [String or null]
  # Optional attribute to add otu_contents
  attr_accessor :otu_contents

  ##### RETURNED DATA ######

  # @!taxon_name_ids
  #   @return [Hash]
  # Returns list of taxon_name_ids
  attr_accessor :taxon_name_ids

  # @!otu_ids
  #   @return [Hash]
  # Returns list of otu_ids
  attr_accessor :otu_ids

  # @!sources_hash
  #   @return [Hash]
  # Returns list of sources
  attr_accessor :source_hash

  # @!results_hash
  #   @return [Hash]
  # Returns taxa sorted hierarchically with all metadata
  attr_accessor :results_hash

  def initialize(
    classification_scope: nil,
    project_id: nil,
    rank_filter: nil,
    otu_filter: nil,
    taxon_name_filter: nil,
    accepted_only: false,
    type_information: false,
    distribution: false,
    otu_contents: false)

    @classification_scope = classification_scope
    @project_id = project_id
    @rank_filter = rank_filter
    @otu_filter = otu_filter
    @taxon_name_filter = taxon_name_filter
    @accepted_only = accepted_only
    @type_information = type_information
    @distribution = distribution
    @otu_contents = otu_contents
    @taxon_name_ids = []
    @otu_ids = []

    #Main logic
    @results_hash = {names: {}, literature: {}}

    build_the_list
  end

  def build_the_list
    results_hash
    return {} if project_id.nil?
    return {} if classification_scope.blank? && otu_filter.blank? && taxon_name_filter.blank?

    taxon = classification_scope.blank? ? nil : TaxonName.find(classification_scope.to_i)
    unless taxon.nil?
      ancestors = get_ancestors(taxon)
      descendants = get_descendants(taxon)
    end

  end

  def get_ancestors(taxon)
    tn = Protonym
      .self_and_ancestors_of(taxon)
      .that_is_valid
      .where.not(rank_class: 'NomenclaturalRank')
      .order('taxon_name_hierarchies.generations DESC')

    #.select('taxon_names.*, sources.id AS source_id, sources.cached_author_string AS source_author_string, sources.year AS source_year, sources.cached AS source_cached')
    #.joins("LEFT OUTER JOIN citations ON citations.citation_object_id = images.id AND citations.citation_object_type = 'TaxonName' AND citations.is_original IS TRUE")
    #  .joins('LEFT OUTER JOIN sources ON citations.source_id = sources.id')
    #"Protonym.named('Zygina').order_by_rank(RANKS)"

    tn.each do |t|
      results_hash.names[t.id] = {name: t.cached,
                                  author_year: t.author_year,
                                  statuses: [],
                                  synonyms: [],

      }
    end
  end

  def get_descendants(taxon)
    tn_ids = Protonym.descendants_of(taxon).that_is_valid.pluck(:id)
    tn = TaxonName.find_by_sql("SELECT taxon_names.* FROM taxon_names INNER JOIN (SELECT a1.d, STRING_AGG(a1.str, '|') AS cl FROM (SELECT taxon_name_hierarchies.descendant_id AS d, a.name AS str FROM taxon_names AS a INNER JOIN taxon_name_hierarchies ON taxon_name_hierarchies.ancestor_id = a.id WHERE taxon_name_hierarchies.descendant_id IN (#{tn_ids.join(', ')}) ORDER BY taxon_name_hierarchies.descendant_id, taxon_name_hierarchies.generations DESC) as a1 GROUP BY a1.d) AS aa ON taxon_names.id = aa.d ORDER BY aa.cl")

    tn.each do |t|
      results_hash.names[t.id] = {name: t.cached,
                                  author_year: t.author_year,
                                  statuses: [],
                                  synonyms: [],
      }
    end
  end

end