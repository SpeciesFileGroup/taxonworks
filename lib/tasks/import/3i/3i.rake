require 'fileutils'

### rake tw:project_import:access3i:import_all data_directory=/Users/proceps/src/sf/import/3i/ no_transaction=true

namespace :tw do
  namespace :project_import do
    namespace :access3i do

    @import_name = '3i'

    # A utility class to index data.
    class ImportedData
      attr_accessor :people_index, :user_index, :publications_index, :citations_index, :genera_index, :images_index,
                    :parent_id_index, :statuses, :taxonno_index, :citation_to_publication_index
      def initialize()
        @people_index = {}              # PeopleID -> Person object
        @user_index = {}                # PeopleID -> User object
        @publications_index = {}        # unique_fields hash -> Surce object
        @citations_index = {}           # NEW_REF_ID -> row
        @citation_to_publication_index = {} # NEW_REF_ID -> source.id
        @genera_index = {}              # GENUS_NUMBER -> row
        @images_index = {}              # TaxonNo -> row
        @parent_id_index = {}           # Rank:TaxonName -> Taxon.id
        @statuses = {}
        @taxonno_index = {}             #TaxonNo -> Taxon.id
      end
    end

    task :import_all => [:data_directory, :environment] do |t|

      @list_of_relationships = []

      @relationship_classes = {
          'type species' => 'TaxonNameRelationship::Typification::Genus',
          'by absolute tautonymy' => 'TaxonNameRelationship::Typification::Genus::Tautonomy::Absolute',
          'by monotypy' => 'TaxonNameRelationship::Typification::Genus::Monotypy::Original',
          'by original designation' => 'TaxonNameRelationship::Typification::Genus::OriginalDesignation',
          'by subsequent designation' => 'TaxonNameRelationship::Typification::Genus::Tautonomy',
          'by subsequent monotypy' => 'TaxonNameRelationship::Typification::Genus::Monotypy::Subsequent',
          'Incorrect original spelling' => 'TaxonNameRelationship::Iczn::Invalidating::Usage::IncorrectOriginalSpelling',
          'Incorrect subsequent spelling' => 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling',
          'Junior objective synonym' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective',
          'Junior subjective synonym' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective',
          'Junior subjective Synonym' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective',
          'Misidentification' => 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misapplication',
          'Nomen nudum: Published as synonym and not validated before 1961' => 'TaxonNameRelationship::Iczn::Invalidating',
          'Objective replacement name: Junior subjective synonym' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective',
          'Unnecessary replacement name' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnnecessaryReplacementName',
          'Suppressed name' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression',
          'Unavailable name: pre-Linnean' => 'TaxonNameRelationship::Iczn::Invalidating',
          'Unjustified emendation' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnjustifiedEmendation',
          'Objective replacement name: Valid Name' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym',
          'Hybrid' => '',
          'Junior homonym' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym',
          'Manuscript name' => '',
          'Nomen nudum' => '',
          'Nomen nudum: no description' => '',
          'Nomen nudum: No type fixation after 1930' => '',
          'Nomen nudum: Published as synonym and not validated before 1961' => '',
          'Unavailable name: Infrasubspecific name' => '',
          'Unavailable name: pre-Linnean' => '',
          'Suppressed name: ICZN official index of rejected and invalid works' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym',
          'Valid Name' => '',
          'Original_Genus' => 'TaxonNameRelationship::OriginalCombination::OriginalGenus',
          'OrigSubgen' => 'TaxonNameRelationship::OriginalCombination::OriginalSubgenus',
          'Original_Species' => 'TaxonNameRelationship::OriginalCombination::OriginalSpecies',
          'Original_Subspecies' => 'TaxonNameRelationship::OriginalCombination::OriginalSubspecies',
          'Original_Infrasubspecies' => 'TaxonNameRelationship::OriginalCombination::OriginalVariety',
          'Incertae sedis' => 'TaxonNameRelationship::Iczn::Validating::UncertainPlacement'
      }

      @classification_classes = {
          'Hybrid' => 'TaxonNameClassification::Iczn::Unavailable::Excluded::NameForHybrid',
          'Junior homonym' => 'TaxonNameClassification::Iczn::Available::Invalid::Homonym',
          'Manuscript name' => 'TaxonNameClassification::Iczn::Unavailable::Excluded::TemporaryName',
          'Nomen nudum' => 'TaxonNameClassification::Iczn::Unavailable::NomenNudum',
          'Nomen nudum: no description' => 'TaxonNameClassification::Iczn::Unavailable::NomenNudum::NoDescription',
          'Nomen nudum: No type fixation after 1930' => 'TaxonNameClassification::Iczn::Unavailable::NomenNudum::NoTypeFixationAfter1930',
          'Nomen nudum: Published as synonym and not validated before 1961' => 'TaxonNameClassification::Iczn::Unavailable::NomenNudum::PublishedAsSynonymAndNotValidatedBefore1961',
          'Unavailable name: Infrasubspecific name' => 'TaxonNameClassification::Iczn::Unavailable::Excluded::Infrasubspecific',
          'Unavailable name: pre-Linnean' => 'TaxonNameClassification::Iczn::Unavailable::PreLinnean',
          'Suppressed name: ICZN official index of rejected and invalid works' => 'TaxonNameClassification::Iczn::Unavailable::Suppressed::OfficialIndexOfRejectedAndInvalidWorks',
          'not latin' => 'TaxonNameClassification::Iczn::Unavailable::NotLatin'
      }


    end

    end
  end
end
