# Paper style comprehansive checklist

class PaperCatalog < Catalog::Nomenclature

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

  # @!valid_only
  #   @return [String or null]
  # Optional attribute. Restrict output to valid_names "valid_only=true"
  attr_accessor :valid_only

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

  # @!results_hash
  #   @return [Hash]
  # Returns taxa sorted hierarchically with all metadata
  attr_accessor :results_hash

  # @!taxon_name_ids
  #   @return [Hash]
  # Returns list of taxon_name_ids
  attr_accessor :taxon_name_ids

  # @!otu_ids
  #   @return [Hash]
  # Returns list of otu_ids
  attr_accessor :otu_ids

  def initialize(
    classification_scope: nil,
    project_id: nil,
    rank_filter: nil,
    valid_only: false,
    type_information: false,
    distribution: false,
    otu_contents: false)

    @classification_scope = classification_scope
    @project_id = project_id
    @rank_filter = rank_filter
    @valid_only = valid_only
    @type_information = type_information
    @distribution = distribution
    @otu_contents = otu_contents
  end
end