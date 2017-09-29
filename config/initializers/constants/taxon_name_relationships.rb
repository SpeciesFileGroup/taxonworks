# Be sure to restart your server (or console) when you modify this file.
#
# Only initialize if the table exists (migrations are done)
if ApplicationRecord.connection.table_exists? 'taxon_name_relationships'

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

    # Array of all ICZN + ICN TaxonNameRelationship classes, as Strings
    STATUS_TAXON_NAME_RELATIONSHIP_NAMES = (ICZN_TAXON_NAME_RELATIONSHIP_NAMES + ICN_TAXON_NAME_RELATIONSHIP_NAMES).freeze

    # Array of all assignable TaxonNameRelationship classes, as Strings
    TAXON_NAME_RELATIONSHIP_NAMES = TAXON_NAME_RELATIONSHIPS.select{|i| i.assignable}.collect{|d| d.to_s}.freeze

    # Array of all invalid TaxonNameRelationship classes, as Strings
    TAXON_NAME_RELATIONSHIP_NAMES_INVALID = TaxonNameRelationship.
      collect_descendants_and_itself_to_s(TaxonNameRelationship::Iczn::Invalidating,
                                          TaxonNameRelationship::Icn::Unaccepting,
                                          TaxonNameRelationship::Icnb::Unaccepting).freeze

    TAXON_NAME_RELATIONSHIP_NAMES_SYNONYM = TaxonNameRelationship.
      collect_descendants_and_itself_to_s(TaxonNameRelationship::Iczn::Invalidating::Synonym,
                                          TaxonNameRelationship::Iczn::Invalidating::Usage,
                                          TaxonNameRelationship::Icn::Unaccepting::Synonym,
                                          TaxonNameRelationship::Icn::Unaccepting::Usage,
                                          TaxonNameRelationship::Icnb::Unaccepting::Synonym,
                                          TaxonNameRelationship::Icnb::Unaccepting::Usage) +
                                         ['TaxonNameRelationship::Iczn::Invalidating',
                                          'TaxonNameRelationship::Icn::Unaccepting',
                                          'TaxonNameRelationship::Icnb::Unaccepting'].freeze


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
    }


    # JSON supporting
    module TaxonNameRelationshipsHelper

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


    TAXON_NAME_RELATIONSHIPS_JSON = {
      iczn: {
        tree: ApplicationEnumeration.nested_subclasses(TaxonNameRelationship::Iczn),
        all: TaxonNameRelationshipsHelper::descendants_collection( TaxonNameRelationship::Iczn ),
        common: TaxonNameRelationshipsHelper.collection([
          TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective,
          TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective,
          TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling,
          TaxonNameRelationship::Iczn::Invalidating::Homonym
        ])
      }, 

      icn: {
        tree: ApplicationEnumeration.nested_subclasses(TaxonNameRelationship::Icn),
        all: TaxonNameRelationshipsHelper::descendants_collection( TaxonNameRelationship::Icn ),
        common: TaxonNameRelationshipsHelper.collection([
          TaxonNameRelationship::Icn::Unaccepting::Synonym::Heterotypic,
          TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic,
          TaxonNameRelationship::Icn::Unaccepting::Usage::Misspelling,
          TaxonNameRelationship::Icn::Unaccepting::Usage::Basionym,
          TaxonNameRelationship::Icn::Unaccepting::Homonym
        ])
      }, 

      icnb: {
        tree: ApplicationEnumeration.nested_subclasses(TaxonNameRelationship::Icnb),
        all: TaxonNameRelationshipsHelper::descendants_collection( TaxonNameRelationship::Icnb ),
        common: TaxonNameRelationshipsHelper.collection([
          TaxonNameRelationship::Icnb::Unaccepting::Synonym::Objective,
          TaxonNameRelationship::Icnb::Unaccepting::Synonym::Subjective,
          TaxonNameRelationship::Icnb::Unaccepting::Usage::Misspelling,
          TaxonNameRelationship::Icnb::Unaccepting::Homonym
        ])
      },

      typification: {
        all:  TaxonNameRelationshipsHelper::descendants_collection( TaxonNameRelationship::Typification ),
        common:  TaxonNameRelationshipsHelper.collection([
          TaxonNameRelationship::Typification::Genus::OriginalDesignation,
          TaxonNameRelationship::Typification::Genus::Monotypy::Original,
          TaxonNameRelationship::Typification::Genus::Monotypy::Subsequent
        ]),
        tree: [] 
      }
    }
end
