# Be sure to restart your server (or console) when you modify this file.

require_dependency Rails.root.to_s + '/app/models/taxon_name_relationship.rb'

# Only initialize if the table exists (migrations are done)
# !! Limit this pattern, see https://github.com/rails/rails/issues/32870 in part
# This is a hack that should be replaced with the pattern in classifications or elsewhere.
begin

  if TaxonNameRelationship.connection && ApplicationRecord.connection.table_exists?('taxon_name_relationships')

    # Why not application_enumerable?

    # JSON supporting
    module TaxonNameRelationshipsConstantHelper

      # @return [Hash]
      def self.collection(relationships)
        relationships.select{|r| r.assignable }.inject({}) {|hsh, c| 
          hsh.merge!(
            c.name => attributes(c)
          )
        }
      end

      # @return [Hash]
      def self.attributes(taxon_name_relationship_klass)
        k = taxon_name_relationship_klass
        n = k.new
        return { 
          subject_status_tag: n.subject_status_tag,
          object_status_tag:  n.object_status_tag,
          valid_object_ranks: k.valid_object_ranks,
          valid_subject_ranks: k.valid_subject_ranks
        }
      end

      # @return [Hash]
      def self.descendants_collection(base_classification)
        collection(base_classification.descendants)
      end
    end

    # All TaxonNameRelationship as Classes.
    # 
    # !! NOT ALL CLASSES ARE ASSIGNABLE
    # !! (see TAXON_NAME_RELATIONSHIP_NAMES for the list of assignable ones)
    #
    # TODO: deprecate this array of Classes for array of strings
    #
    TAXON_NAME_RELATIONSHIPS = TaxonNameRelationship.descendants.freeze

    # Array of all ICZN TaxonNameRelationship classes, as Strings
    ICZN_TAXON_NAME_RELATIONSHIP_NAMES = TaxonNameRelationship::Iczn.descendants.collect{|d| d.to_s}.freeze

    # Array of all ICN TaxonNameRelationship classes, as Strings
    ICN_TAXON_NAME_RELATIONSHIP_NAMES = TaxonNameRelationship::Icn.descendants.collect{|d| d.to_s}.freeze

    # Array of all ICNP TaxonNameRelationship classes, as Strings
    ICNP_TAXON_NAME_RELATIONSHIP_NAMES = TaxonNameRelationship::Icnp.descendants.collect{|d| d.to_s}.freeze

    # Array of all ICVCN TaxonNameRelationship classes, as Strings
    ICVCN_TAXON_NAME_RELATIONSHIP_NAMES = TaxonNameRelationship::Icvcn.descendants.collect{|d| d.to_s}.freeze

    # Array of all ICZN + ICN TaxonNameRelationship classes, as Strings
    STATUS_TAXON_NAME_RELATIONSHIP_NAMES = (ICZN_TAXON_NAME_RELATIONSHIP_NAMES + ICN_TAXON_NAME_RELATIONSHIP_NAMES + ICNP_TAXON_NAME_RELATIONSHIP_NAMES + ICVCN_TAXON_NAME_RELATIONSHIP_NAMES).freeze

    # Array of all assignable TaxonNameRelationship classes, as Strings
    TAXON_NAME_RELATIONSHIP_NAMES = TAXON_NAME_RELATIONSHIPS.select{|i| i.assignable}.collect{|d| d.to_s}.freeze

    # Array of all invalid TaxonNameRelationship classes, as Strings
    TAXON_NAME_RELATIONSHIP_NAMES_INVALID = TaxonNameRelationship.
      collect_descendants_and_itself_to_s(
        TaxonNameRelationship::Iczn::Invalidating,
        TaxonNameRelationship::Icn::Unaccepting,
        TaxonNameRelationship::Icnp::Unaccepting,
        TaxonNameRelationship::Icvcn::Unaccepting).freeze

    TAXON_NAME_RELATIONSHIP_NAMES_CLASSIFICATION = %w{
      TaxonNameRelationship::Iczn::Validating::UncertainPlacement
      TaxonNameRelationship::SourceClassifiedAs}.freeze

    COMBINATION_TAXON_NAME_RELATIONSHIP_NAMES = TaxonNameRelationship.
      collect_descendants_to_s(
        TaxonNameRelationship::Combination,
        TaxonNameRelationship::OriginalCombination)

    TAXON_NAME_RELATIONSHIP_NAMES_SYNONYM = TaxonNameRelationship.collect_descendants_and_itself_to_s(
        TaxonNameRelationship::Iczn::Invalidating::Synonym,
        TaxonNameRelationship::Iczn::Invalidating::Usage,
        TaxonNameRelationship::Icn::Unaccepting::Synonym,
        TaxonNameRelationship::Icn::Unaccepting::Usage,
        TaxonNameRelationship::Icnp::Unaccepting::Synonym,
        TaxonNameRelationship::Icnp::Unaccepting::Usage,
        TaxonNameRelationship::Icvcn::Unaccepting) +
       %w{ TaxonNameRelationship::Iczn::Invalidating
       TaxonNameRelationship::Icn::Unaccepting
       TaxonNameRelationship::Icnp::Unaccepting
       TaxonNameRelationship::Icvcn::Unaccepting}.freeze

    TAXON_NAME_RELATIONSHIP_NAMES_MISSPELLING = %w{
      TaxonNameRelationship::Icn::Unaccepting::Usage::Misspelling'
      TaxonNameRelationship::Icnp::Unaccepting::Usage::Misspelling
      TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling
      TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnjustifiedEmendation
      TaxonNameRelationship::Iczn::Invalidating::Usage::FamilyGroupNameForm
      TaxonNameRelationship::Iczn::Invalidating::Usage::FamilyGroupNameOriginalForm
      TaxonNameRelationship::Iczn::Invalidating::Usage::IncorrectOriginalSpelling}.freeze

    TAXON_NAME_RELATIONSHIP_NAMES_MISSPELLING_AUTHOR_STRING = %w{
      TaxonNameRelationship::Icn::Unaccepting::Usage::Misspelling
      TaxonNameRelationship::Icnp::Unaccepting::Usage::Misspelling
      TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling
      TaxonNameRelationship::Iczn::Invalidating::Usage::FamilyGroupNameForm
      TaxonNameRelationship::Iczn::Invalidating::Usage::FamilyGroupNameOriginalForm
      TaxonNameRelationship::Iczn::Invalidating::Usage::IncorrectOriginalSpelling}.freeze

    TAXON_NAME_RELATIONSHIP_NAMES_MISSPELLING_ONLY = %w{
      TaxonNameRelationship::Icn::Unaccepting::Usage::Misspelling'
      TaxonNameRelationship::Icnp::Unaccepting::Usage::Misspelling'
      TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnjustifiedEmendation'
      TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling'
      TaxonNameRelationship::Iczn::Invalidating::Usage::IncorrectOriginalSpelling}.freeze

    TAXON_NAME_RELATIONSHIP_NAMES_MISSPELLING_AND_MISAPPLICATION = TAXON_NAME_RELATIONSHIP_NAMES_MISSPELLING + %w{
      TaxonNameRelationship::Icn::Unaccepting::Misapplication
      TaxonNameRelationship::Icnp::Unaccepting::Misapplication
      TaxonNameRelationship::Iczn::Invalidating::Misapplication}

    # TODO: check .assignable property prior to building

    object_select, subject_select = [], []
    TaxonNameRelationship.descendants.each do |r|
      if r.respond_to?(:assignment_method)
        subject_select.push([r.assignment_method.to_s.humanize, r.to_s])
      end
      if r.respond_to?(:inverse_assignment_method)
        object_select.push([r.inverse_assignment_method.to_s.humanize, r.to_s])
      end
    end

    TAXON_NAME_RELATIONSHIPS_SUBJECT_SELECT = subject_select.freeze
    TAXON_NAME_RELATIONSHIPS_OBJECT_SELECT = object_select.freeze

    TAXON_NAME_RELATIONSHIPS_TYPE_JSON = {
      family:  TAXON_NAME_RELATIONSHIPS_OBJECT_SELECT.select{|a,b| b =~ /.*::Typification::Family/},
      genus: TAXON_NAME_RELATIONSHIPS_OBJECT_SELECT.select{|a,b| b =~ /.*::Typification::Genus/}
    }.freeze

    # { genus: 'TaxonNameRelationship::Combination::Genus, ... }
    TAXON_NAME_RELATIONSHIP_COMBINATION_TYPES = TaxonNameRelationship::Combination.descendants.inject({}){|hsh, a| hsh.merge!( a.rank_name.to_sym => a.name)}.freeze

    TAXON_NAME_RELATIONSHIPS_JSON = {
        iczn: {
        tree: ApplicationEnumeration.nested_subclasses(TaxonNameRelationship::Iczn),
        all: TaxonNameRelationshipsConstantHelper::descendants_collection( TaxonNameRelationship::Iczn ),
        common: TaxonNameRelationshipsConstantHelper.collection([
          TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective,
          TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective,
          TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling,
          TaxonNameRelationship::Iczn::Invalidating::Homonym,
          TaxonNameRelationship::Iczn::Invalidating
        ])
      },

        icn: {
        tree: ApplicationEnumeration.nested_subclasses(TaxonNameRelationship::Icn),
        all: TaxonNameRelationshipsConstantHelper::descendants_collection( TaxonNameRelationship::Icn ),
        common: TaxonNameRelationshipsConstantHelper.collection([
          TaxonNameRelationship::Icn::Unaccepting::Synonym::Heterotypic,
          TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic,
          TaxonNameRelationship::Icn::Unaccepting::Usage::Misspelling,
          TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic::Basionym,
          TaxonNameRelationship::Icn::Unaccepting::Homonym
        ])
      },

        icnp: {
        tree: ApplicationEnumeration.nested_subclasses(TaxonNameRelationship::Icnp),
        all: TaxonNameRelationshipsConstantHelper::descendants_collection( TaxonNameRelationship::Icnp ),
        common: TaxonNameRelationshipsConstantHelper.collection([
          TaxonNameRelationship::Icnp::Unaccepting::Synonym::Homotypic,
          TaxonNameRelationship::Icnp::Unaccepting::Synonym::Heterotypic,
          TaxonNameRelationship::Icnp::Unaccepting::Usage::Misspelling,
          TaxonNameRelationship::Icnp::Unaccepting::Homonym
        ])
      },

        icvcn: {
        tree: ApplicationEnumeration.nested_subclasses(TaxonNameRelationship::Icvcn),
        all: TaxonNameRelationshipsConstantHelper::descendants_collection( TaxonNameRelationship::Icvcn ),
        common: TaxonNameRelationshipsConstantHelper.collection([
          TaxonNameRelationship::Icvcn::Unaccepting
        ])
      },

        typification: {
        all:  TaxonNameRelationshipsConstantHelper::descendants_collection( TaxonNameRelationship::Typification ),
        common:  TaxonNameRelationshipsConstantHelper.collection([
          TaxonNameRelationship::Typification::Genus::Original::OriginalDesignation,
          TaxonNameRelationship::Typification::Genus::Original::OriginalMonotypy,
          TaxonNameRelationship::Typification::Genus::Subsequent::SubsequentDesignation
        ]),
        tree: []
      }
    }.freeze
  end

rescue ActiveRecord::NoDatabaseError
  puts Rainbow('skipping taxon name relationships constants initialization (this is ok if you are migrating the database)').yellow.bold
  true 
end
