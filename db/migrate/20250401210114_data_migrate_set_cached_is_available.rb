#
# !! Time to completion is > 5 minutes for 1my rows
#
class DataMigrateSetCachedIsAvailable < ActiveRecord::Migration[7.2]
  def change

    # Ugly, but we have a init/config race problem

    x = ["TaxonNameRelationship::Icn::Unaccepting::Usage::Misspelling",
    "TaxonNameRelationship::Icnp::Unaccepting::Usage::Misspelling",
    "TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling",
    "TaxonNameRelationship::Iczn::Invalidating::Usage::FamilyGroupNameForm",
    "TaxonNameRelationship::Iczn::Invalidating::Usage::FamilyGroupNameOriginalForm",
    "TaxonNameRelationship::Iczn::Invalidating::Usage::IncorrectOriginalSpelling",
    "TaxonNameRelationship::Icn::Unaccepting::Misapplication",
    "TaxonNameRelationship::Icnp::Unaccepting::Misapplication",
    "TaxonNameRelationship::Iczn::Invalidating::Misapplication"]

    y = ["TaxonNameClassification::Iczn::Unavailable",
    "TaxonNameClassification::Iczn::Unavailable::Suppressed",
    "TaxonNameClassification::Iczn::Unavailable::NonBinominal",
    "TaxonNameClassification::Iczn::Unavailable::NomenNudum",
    "TaxonNameClassification::Iczn::Unavailable::Excluded",
    "TaxonNameClassification::Iczn::Unavailable::ElectronicPublicationNotRegisteredInZoobank",
    "TaxonNameClassification::Iczn::Unavailable::ElectronicPublicationWithoutIssnOrIsbn",
    "TaxonNameClassification::Iczn::Unavailable::ElectronicPublicationNotInPdfFormat",
    "TaxonNameClassification::Iczn::Unavailable::ElectronicOnlyPublicationBefore2012",
    "TaxonNameClassification::Iczn::Unavailable::VarietyOrFormAfter1960",
    "TaxonNameClassification::Iczn::Unavailable::UnavailableUnderIczn",
    "TaxonNameClassification::Iczn::Unavailable::UnavailableAndRejectedByAuthorBefore2000",
    "TaxonNameClassification::Iczn::Unavailable::UnavailableAndNotUsedAsValidBefore2000",
    "TaxonNameClassification::Iczn::Unavailable::PreLinnean",
    "TaxonNameClassification::Iczn::Unavailable::NotScientificPlural",
    "TaxonNameClassification::Iczn::Unavailable::NotNounOrAdjective",
    "TaxonNameClassification::Iczn::Unavailable::NotNounInNominativeSingular",
    "TaxonNameClassification::Iczn::Unavailable::NotNominativePlural",
    "TaxonNameClassification::Iczn::Unavailable::NotLatinizedBefore1900AndNotAccepted",
    "TaxonNameClassification::Iczn::Unavailable::NotLatinizedAfter1899",
    "TaxonNameClassification::Iczn::Unavailable::NotLatin",
    "TaxonNameClassification::Iczn::Unavailable::LessThanTwoLetters",
    "TaxonNameClassification::Iczn::Unavailable::BasedOnSuppressedGenus",
    "TaxonNameClassification::Iczn::Unavailable::Suppressed::OfficialIndexOfRejectedSpecificNamesInZoology",
    "TaxonNameClassification::Iczn::Unavailable::Suppressed::OfficialIndexOfRejectedGenericNamesInZoology",
    "TaxonNameClassification::Iczn::Unavailable::Suppressed::OfficialIndexOfRejectedFamilyGroupNamesInZoology",
    "TaxonNameClassification::Iczn::Unavailable::Suppressed::OfficialIndexOfRejectedAndInvalidWorksInZoology",
    "TaxonNameClassification::Iczn::Unavailable::Suppressed::NotInOfficialListOfAvailableNamesInZoology",
    "TaxonNameClassification::Iczn::Unavailable::NonBinominal::SubspeciesNotTrinominal",
    "TaxonNameClassification::Iczn::Unavailable::NonBinominal::SubgenusNotIntercalare",
    "TaxonNameClassification::Iczn::Unavailable::NonBinominal::SpeciesNotBinominal",
    "TaxonNameClassification::Iczn::Unavailable::NonBinominal::NotUninominal",
    "TaxonNameClassification::Iczn::Unavailable::NomenNudum::AmbiguousGenericPlacement",
    "TaxonNameClassification::Iczn::Unavailable::NomenNudum::ReplacementNameWithoutTypeFixationAfter1930",
    "TaxonNameClassification::Iczn::Unavailable::NomenNudum::PublishedAsSynonymAndNotValidatedBefore1961",
    "TaxonNameClassification::Iczn::Unavailable::NomenNudum::PublishedAsSynonymAfter1960",
    "TaxonNameClassification::Iczn::Unavailable::NomenNudum::NotIndicatedAsNewAfter1999",
    "TaxonNameClassification::Iczn::Unavailable::NomenNudum::NotFromGenusName",
    "TaxonNameClassification::Iczn::Unavailable::NomenNudum::NotBasedOnAvailableGenusName",
    "TaxonNameClassification::Iczn::Unavailable::NomenNudum::NoTypeSpecimenFixationAfter1999",
    "TaxonNameClassification::Iczn::Unavailable::NomenNudum::NoTypeGenusCitationAfter1999",
    "TaxonNameClassification::Iczn::Unavailable::NomenNudum::NoTypeFixationAfter1930",
    "TaxonNameClassification::Iczn::Unavailable::NomenNudum::NoTypeDepositionStatementAfter1999",
    "TaxonNameClassification::Iczn::Unavailable::NomenNudum::NoDiagnosisAfter1930AndRejectedBefore2000",
    "TaxonNameClassification::Iczn::Unavailable::NomenNudum::NoDiagnosisAfter1930",
    "TaxonNameClassification::Iczn::Unavailable::NomenNudum::NoDescription",
    "TaxonNameClassification::Iczn::Unavailable::NomenNudum::InterpolatedName",
    "TaxonNameClassification::Iczn::Unavailable::NomenNudum::IchnotaxonWithoutTypeSpeciesAfter1999",
    "TaxonNameClassification::Iczn::Unavailable::NomenNudum::ConditionallyProposedAfter1960",
    "TaxonNameClassification::Iczn::Unavailable::NomenNudum::CitationOfUnavailableName",
    "TaxonNameClassification::Iczn::Unavailable::NomenNudum::AnonymousAuthorshipAfter1950",
    "TaxonNameClassification::Iczn::Unavailable::Excluded::ZoologicalFormula",
    "TaxonNameClassification::Iczn::Unavailable::Excluded::WorkOfExtantAnimalAfter1930",
    "TaxonNameClassification::Iczn::Unavailable::Excluded::TemporaryName",
    "TaxonNameClassification::Iczn::Unavailable::Excluded::NotForNomenclature",
    "TaxonNameClassification::Iczn::Unavailable::Excluded::NameForTerratologicalSpecimen",
    "TaxonNameClassification::Iczn::Unavailable::Excluded::NameForHybrid",
    "TaxonNameClassification::Iczn::Unavailable::Excluded::Infrasubspecific",
    "TaxonNameClassification::Iczn::Unavailable::Excluded::HypotheticalConcept",
    "TaxonNameClassification::Iczn::Unavailable::Excluded::BasedOnFossilGenusFormula",
    "TaxonNameClassification::Iczn::CollectiveGroup",
    "TaxonNameClassification::Iczn::Fossil::Ichnotaxon",
    "TaxonNameClassification::Icn::NotEffectivelyPublished",
    "TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished",
    "TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished::NotLatin",
    "TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished::Provisional",
    "TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished::Tautonym",
    "TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished::RejectedPublication",
    "TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished::NomenNudum",
    "TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished::AsSynonym",
    "TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished::NonBinomial",
    "TaxonNameClassification::Icnp::NotEffectivelyPublished",
    "TaxonNameClassification::Icnp::EffectivelyPublished::InvalidlyPublished",
    "TaxonNameClassification::Icnp::EffectivelyPublished::InvalidlyPublished::NomenNudum"]


    a = Protonym.joins(:taxon_name_relationships).where(taxon_name_relationships: {type: x})
    b = Protonym.joins(:taxon_name_classifications).where(taxon_name_classifications: {type: y})
    c = ::Queries.union(TaxonName, [a,b]).in_batches

    c.update_all(cached_is_available: false)

    d = TaxonName.connection.execute("UPDATE taxon_names SET cached_is_available = '1' WHERE cached_is_available is null;")
  end
end
