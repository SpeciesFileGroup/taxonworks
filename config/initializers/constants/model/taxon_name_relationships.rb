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
          object_status_tag:  n.object_status_tag
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

    # Array of all ICNB TaxonNameRelationship classes, as Strings
    ICNB_TAXON_NAME_RELATIONSHIP_NAMES = TaxonNameRelationship::Icnb.descendants.collect{|d| d.to_s}.freeze

    # Array of all ICTV TaxonNameRelationship classes, as Strings
    ICTV_TAXON_NAME_RELATIONSHIP_NAMES = TaxonNameRelationship::Ictv.descendants.collect{|d| d.to_s}.freeze

    # Array of all ICZN + ICN TaxonNameRelationship classes, as Strings
    STATUS_TAXON_NAME_RELATIONSHIP_NAMES = (ICZN_TAXON_NAME_RELATIONSHIP_NAMES + ICN_TAXON_NAME_RELATIONSHIP_NAMES + ICNB_TAXON_NAME_RELATIONSHIP_NAMES + ICTV_TAXON_NAME_RELATIONSHIP_NAMES).freeze

    # Array of all assignable TaxonNameRelationship classes, as Strings
    TAXON_NAME_RELATIONSHIP_NAMES = TAXON_NAME_RELATIONSHIPS.select{|i| i.assignable}.collect{|d| d.to_s}.freeze

    # Array of all invalid TaxonNameRelationship classes, as Strings
    TAXON_NAME_RELATIONSHIP_NAMES_INVALID = TaxonNameRelationship.
      collect_descendants_and_itself_to_s(TaxonNameRelationship::Iczn::Invalidating,
                                          TaxonNameRelationship::Icn::Unaccepting,
                                          TaxonNameRelationship::Icnb::Unaccepting,
                                          TaxonNameRelationship::Ictv::Unaccepting).freeze

    TAXON_NAME_RELATIONSHIP_NAMES_SYNONYM = TaxonNameRelationship.
      collect_descendants_and_itself_to_s(TaxonNameRelationship::Iczn::Invalidating::Synonym,
                                          TaxonNameRelationship::Iczn::Invalidating::Usage,
                                          TaxonNameRelationship::Icn::Unaccepting::Synonym,
                                          TaxonNameRelationship::Icn::Unaccepting::Usage,
                                          TaxonNameRelationship::Icnb::Unaccepting::Synonym,
                                          TaxonNameRelationship::Icnb::Unaccepting::Usage,
                                          TaxonNameRelationship::Ictv::Unaccepting) +
                                         ['TaxonNameRelationship::Iczn::Invalidating',
                                          'TaxonNameRelationship::Icn::Unaccepting',
                                          'TaxonNameRelationship::Icnb::Unaccepting',
                                          'TaxonNameRelationship::Ictv::Unaccepting'].freeze

    TAXON_NAME_RELATIONSHIP_NAMES_MISSPELLING = ['TaxonNameRelationship::Icn::Unaccepting::Usage::Misspelling',
                                                 'TaxonNameRelationship::Icnb::Unaccepting::Usage::Misspelling',
                                                 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling',
                                                 'TaxonNameRelationship::Iczn::Invalidating::Usage::IncorrectOriginalSpelling'].freeze


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
          TaxonNameRelationship::Iczn::Invalidating::Homonym
        ])
      },

      icn: {
        tree: ApplicationEnumeration.nested_subclasses(TaxonNameRelationship::Icn),
        all: TaxonNameRelationshipsConstantHelper::descendants_collection( TaxonNameRelationship::Icn ),
        common: TaxonNameRelationshipsConstantHelper.collection([
          TaxonNameRelationship::Icn::Unaccepting::Synonym::Heterotypic,
          TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic,
          TaxonNameRelationship::Icn::Unaccepting::Usage::Misspelling,
          TaxonNameRelationship::Icn::Unaccepting::Usage::Basionym,
          TaxonNameRelationship::Icn::Unaccepting::Homonym
        ])
      },

      icnb: {
        tree: ApplicationEnumeration.nested_subclasses(TaxonNameRelationship::Icnb),
        all: TaxonNameRelationshipsConstantHelper::descendants_collection( TaxonNameRelationship::Icnb ),
        common: TaxonNameRelationshipsConstantHelper.collection([
          TaxonNameRelationship::Icnb::Unaccepting::Synonym::Objective,
          TaxonNameRelationship::Icnb::Unaccepting::Synonym::Subjective,
          TaxonNameRelationship::Icnb::Unaccepting::Usage::Misspelling,
          TaxonNameRelationship::Icnb::Unaccepting::Homonym
        ])
      },

      ictv: {
        tree: ApplicationEnumeration.nested_subclasses(TaxonNameRelationship::Ictv),
        all: TaxonNameRelationshipsConstantHelper::descendants_collection( TaxonNameRelationship::Ictv ),
        common: TaxonNameRelationshipsConstantHelper.collection([
          TaxonNameRelationship::Ictv::Unaccepting
        ])
      },

      typification: {
        all:  TaxonNameRelationshipsConstantHelper::descendants_collection( TaxonNameRelationship::Typification ),
        common:  TaxonNameRelationshipsConstantHelper.collection([
          TaxonNameRelationship::Typification::Genus::OriginalDesignation,
          TaxonNameRelationship::Typification::Genus::Monotypy::Original,
          TaxonNameRelationship::Typification::Genus::Monotypy::Subsequent
        ]),
        tree: []
      }
    }.freeze
  end

rescue ActiveRecord::NoDatabaseError
  puts Rainbow('skipping taxon name relationships constants initialization (this is ok if you are migrating the database)').yellow.bold
  true 
end
