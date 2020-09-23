export default [
  {
    name: 'type',
    qualName: 'http://purl.org/dc/terms/type',
    description: 'The nature or genre of the resource. For Darwin Core, recommended best practice is to use the name of the class that defines the root of the record.',
    examples: '"StillImage", "MovingImage", "Sound", "PhysicalObject", "Event"'
  },
  {
    name: 'modified',
    qualName: 'http://purl.org/dc/terms/modified',
    description: 'The most recent date-time on which the resource was changed. For Darwin Core, recommended best practice is to use an encoding scheme, such as ISO 8601:2004(E)',
    examples: '"1963-03-08T14:07-0600" is 8 Mar 1963 2:07pm in the time zone six hours earlier than UTC, "2009-02-20T08:40Z" is 20 Feb 2009 8:40am UTC, "1809-02-12" is 12 Feb 1809, "1906-06" is Jun 1906, "1971" is just that year, "2007-03-01T13:00:00Z/2008-05-11T15:30:00Z" is the interval between 1 Mar 2007 1pm UTC and 11 May 2008 3:30pm UTC, "2007-11-13/15" is the interval between 13 Nov 2007 and 15 Nov 2007'
  },
  {
    name: 'language',
    qualName: 'http://purl.org/dc/terms/language',
    description: 'A language of the resource. Recommended best practice is to use a controlled vocabulary such as RFC 4646 [RFC4646]',
    examples: '"en" for English, "es" for Spanish'
  },
  {
    name: 'rights',
    qualName: 'http://purl.org/dc/terms/rights',
    description: 'Information about rights held in and over the resource. Typically, rights information includes a statement about various property rights associated with the resource, including intellectual property rights',
    examples: '"Content licensed under Creative Commons Attribution 3.0 United States License"'
  },
  {
    name: 'rightsHolder',
    qualName: 'http://purl.org/dc/terms/rightsHolder',
    description: 'A person or organization owning or managing rights over the resource',
    examples: '"The Regents of the University of California."'
  },
  {
    name: 'accessRights',
    qualName: 'http://purl.org/dc/terms/accessRights',
    description: 'Information about who can access the resource or an indication of its security status. Access Rights may include information regarding access or restrictions based on privacy, security, or other policies',
    examples: '"not-for-profit use only"'
  },
  {
    name: 'bibliographicCitation',
    qualName: 'http://purl.org/dc/terms/bibliographicCitation',
    description: 'A bibliographic reference for the resource as a statement indicating how this record should be cited (attributed) when used. Recommended practice is to include sufficient bibliographic detail to identify the resource as unambiguously as possible',
    examples: '"Ctenomys sociabilis (MVZ 165861)" for a specimen, "Oliver P. Pearson. 1985. Los tuco-tucos (genera Ctenomys) de los Parques Nacionales Lanin y Nahuel Huapi, Argentina Historia Natural, 5(37):337-343." for a Taxon'
  },
  {
    name: 'references',
    qualName: 'http://purl.org/dc/terms/references',
    description: 'A URL to a related resource that is referenced, cited, or otherwise pointed to by the described resource. Often another webpage showing the same, but richer resource',
    examples: 'http://www.itis.gov/servlet/SingleRpt/SingleRpt?search_topic=TSN&search_value=552479'
  },
  {
    name: 'institutionID',
    qualName: 'http://rs.tdwg.org/dwc/terms/institutionID',
    description: 'An identifier for the institution having custody of the object(s) or information referred to in the record.',
    examples: ''
  },
  {
    name: 'collectionID',
    qualName: 'http://rs.tdwg.org/dwc/terms/collectionID',
    description: 'An identifier for the collection or dataset from which the record was derived. For physical specimens, the recommended best practice is to use the identifier in a collections registry such as the Biodiversity Collections Index (http://www.biodiversitycollectionsindex.org/).',
    examples: '"urn:lsid:biocol.org:col:34818"'
  },
  {
    name: 'datasetID',
    qualName: 'http://rs.tdwg.org/dwc/terms/datasetID',
    description: 'An identifier for the set of data. May be a global unique identifier or an identifier specific to a collection or institution.',
    examples: ''
  },
  {
    name: 'institutionCode',
    qualName: 'http://rs.tdwg.org/dwc/terms/institutionCode',
    description: 'The name (or acronym) in use by the institution having custody of the object(s) or information referred to in the record.',
    examples: '"MVZ", "FMNH", "AKN-CLO", "University of California Museum of Paleontology (UCMP)"'
  },
  {
    name: 'collectionCode',
    qualName: 'http://rs.tdwg.org/dwc/terms/collectionCode',
    description: 'The name, acronym, coden, or initialism identifying the collection or data set from which the record was derived.',
    examples: '"Mammals", "Hildebrandt", "eBird"'
  },
  {
    name: 'datasetName',
    qualName: 'http://rs.tdwg.org/dwc/terms/datasetName',
    description: 'The name identifying the data set from which the record was derived.',
    examples: '"Grinnell Resurvey Mammals", "Lacey Ctenomys Recaptures"'
  },
  {
    name: 'ownerInstitutionCode',
    qualName: 'http://rs.tdwg.org/dwc/terms/ownerInstitutionCode',
    description: 'The name (or acronym) in use by the institution having ownership of the object(s) or information referred to in the record.',
    examples: '"NPS", "APN", "InBio"'
  },
  {
    name: 'basisOfRecord',
    qualName: 'http://rs.tdwg.org/dwc/terms/basisOfRecord',
    description: 'The specific nature of the data record - a subtype of the dcterms:type. Recommended best practice is to use a controlled vocabulary such as the Darwin Core Type Vocabulary (http://rs.tdwg.org/dwc/terms/type-vocabulary/index.htm).',
    examples: '"PreservedSpecimen", "FossilSpecimen", "LivingSpecimen", "HumanObservation", "MachineObservation"'
  },
  {
    name: 'informationWithheld',
    qualName: 'http://rs.tdwg.org/dwc/terms/informationWithheld',
    description: 'Additional information that exists, but that has not been shared in the given record.',
    examples: '"location information not given for endangered species", "collector identities withheld", "ask about tissue samples"'
  },
  {
    name: 'dataGeneralizations',
    qualName: 'http://rs.tdwg.org/dwc/terms/dataGeneralizations',
    description: 'Actions taken to make the shared data less specific or complete than in its original form. Suggests that alternative data of higher quality may be available on request.',
    examples: '"Coordinates generalized from original GPS coordinates to the nearest half degree grid cell"'
  },
  {
    name: 'dynamicProperties',
    qualName: 'http://rs.tdwg.org/dwc/terms/dynamicProperties',
    description: 'A list (concatenated and separated) of additional measurements, facts, characteristics, or assertions about the record. Meant to provide a mechanism for structured content such as key-value pairs.',
    examples: '"tragusLengthInMeters=0.014; weightInGrams=120", "heightInMeters=1.5", "natureOfID=expert identification; identificationEvidence=cytochrome B sequence", "relativeHumidity=28; airTemperatureInC=22; sampleSizeInKilograms=10", "aspectHeading=277; slopeInDegrees=6", "iucnStatus=vulnerable; taxonDistribution=Neuquen, Argentina"'
  },
  {
    name: 'source',
    qualName: 'http://purl.org/dc/terms/source',
    description: 'Deprecated in favor over dcterm:references! A URI link to the source of this record. A link to a webpage or RESTful webservice is recommended.  URI is mandatory format.',
    examples: 'http://ww2.bgbm.org/herbarium/view_large.cfm?SpecimenPK=100611&idThumb=310161&SpecimenSequenz=1&loan=0'
  },
  {
    name: 'materialSampleID',
    qualName: 'http://rs.tdwg.org/dwc/terms/materialSampleID',
    description: 'An identifier for the MaterialSample (as opposed to a particular digital record of the material sample). In the absence of a persistent global unique identifier, construct one from a combination of identifiers in the record that will most closely make the materialSampleID globally unique.'
  },
  {
    name: 'occurrenceID',
    qualName: 'http://rs.tdwg.org/dwc/terms/occurrenceID',
    description: 'An identifier for the Occurrence (as opposed to a particular digital record of the occurrence). In the absence of a persistent global unique identifier, construct one from a combination of identifiers in the record that will most closely make the occurrenceID globally unique.',
    examples: 'For a specimen in the absence of a bona fide global unique identifier, for example, use the form: "urn:catalog:[institutionCode]:[collectionCode]:[catalogNumber]. "urn:lsid:nhm.ku.edu:Herps:32", "urn:catalog:FMNH:Mammal:145732"'
  },
  {
    name: 'catalogNumber',
    qualName: 'http://rs.tdwg.org/dwc/terms/catalogNumber',
    description: 'An identifier (preferably unique) for the record within the data set or collection.',
    examples: '"2008.1334", "145732a", "145732"'
  },
  {
    name: 'occurrenceRemarks',
    qualName: 'http://rs.tdwg.org/dwc/terms/occurrenceRemarks',
    description: 'Comments or notes about the Occurrence.',
    examples: '"found dead on road"'
  },
  {
    name: 'recordNumber',
    qualName: 'http://rs.tdwg.org/dwc/terms/recordNumber',
    description: "An identifier given to the Occurrence at the time it was recorded. Often serves as a link between field notes and an Occurrence record, such as a specimen collector's number.",
    examples: '"OPP 7101"'
  },
  {
    name: 'recordedBy',
    qualName: 'http://rs.tdwg.org/dwc/terms/recordedBy',
    description: 'A list (concatenated and separated) of names of people, groups, or organizations responsible for recording the original Occurrence. The primary collector or observer, especially one who applies a personal identifier (recordNumber), should be listed first.',
    examples: '"Oliver P. Pearson; Anita K. Pearson" where the value in recordNumber "OPP 7101" corresponds to the number for the specimen in the field catalog (collector number) of Oliver P. Pearson.'
  },
  {
    name: 'individualID',
    qualName: 'http://rs.tdwg.org/dwc/terms/individualID',
    description: 'An identifier for an individual or named group of individual organisms represented in the Occurrence. Meant to accommodate resampling of the same individual or group for monitoring purposes. May be a global unique identifier or an identifier specific to a data set.',
    examples: '"U.amer. 44", "Smedley", "Orca J 23"'
  },
  {
    name: 'individualCount',
    qualName: 'http://rs.tdwg.org/dwc/terms/individualCount',
    description: 'The number of individuals represented present at the time of the Occurrence.',
    examples: '"1", "25"'
  },
  {
    name: 'sex',
    qualName: 'http://rs.tdwg.org/dwc/terms/sex',
    description: 'The sex of the biological individual(s) represented in the Occurrence. Recommended best practice is to use a controlled vocabulary.',
    examples: '"female", "hermaphrodite", "male"'
  },
  {
    name: 'lifeStage',
    qualName: 'http://rs.tdwg.org/dwc/terms/lifeStage',
    description: 'The age class or life stage of the biological individual(s) at the time the Occurrence was recorded. Recommended best practice is to use a controlled vocabulary.',
    examples: '"egg", "eft", "juvenile", "adult", "2 adults 4 juveniles"'
  },
  {
    name: 'reproductiveCondition',
    qualName: 'http://rs.tdwg.org/dwc/terms/reproductiveCondition',
    description: 'The reproductive condition of the biological individual(s) represented in the Occurrence. Recommended best practice is to use a controlled vocabulary.',
    examples: 'Examples" "non-reproductive", "pregnant", "in bloom", "fruit-bearing"'
  },
  {
    name: 'behavior',
    qualName: 'http://rs.tdwg.org/dwc/terms/behavior',
    description: 'A description of the behavior shown by the subject at the time the Occurrence was recorded.  Recommended best practice is to use a controlled vocabulary.',
    examples: '"roosting", "foraging", "running"'
  },
  {
    name: 'establishmentMeans',
    qualName: 'http://rs.tdwg.org/dwc/terms/establishmentMeans',
    description: 'The process by which the biological individual(s) represented in the Occurrence became established at the location. Recommended best practice is to use a controlled vocabulary.',
    examples: '"cultivated", "invasive", "escaped from captivity", "wild", "native"'
  },
  {
    name: 'occurrenceStatus',
    qualName: 'http://rs.tdwg.org/dwc/terms/occurrenceStatus',
    description: 'A statement about the presence or absence of a Taxon at a Location. Recommended best practice is to use a controlled vocabulary.',
    examples: '"present", "absent"'
  },
  {
    name: 'preparations',
    qualName: 'http://rs.tdwg.org/dwc/terms/preparations',
    description: 'A list (concatenated and separated) of preparations and preservation methods for a specimen.',
    examples: '"skin; skull; skeleton", "whole animal (ETOH); tissue (EDTA)", "fossil", "cast", "photograph", "DNA extract"'
  },
  {
    name: 'disposition',
    qualName: 'http://rs.tdwg.org/dwc/terms/disposition',
    description: 'The current state of a specimen with respect to the collection identified in collectionCode or collectionID. Recommended best practice is to use a controlled vocabulary.',
    examples: '"in collection", "missing", "voucher elsewhere", "duplicates elsewhere"'
  },
  {
    name: 'otherCatalogNumbers',
    qualName: 'http://rs.tdwg.org/dwc/terms/otherCatalogNumbers',
    description: 'A list (concatenated and separated) of previous or alternate fully qualified catalog numbers or other human-used identifiers for the same Occurrence, whether in the current or any other data set or collection.',
    examples: '"FMNH:Mammal:1234", "NPS YELLO6778; MBG 33424"'
  },
  {
    name: 'previousIdentifications',
    qualName: 'http://rs.tdwg.org/dwc/terms/previousIdentifications',
    description: 'A list (concatenated and separated) of previous assignments of names to the Occurrence.',
    examples: '"Anthus sp., field ID by G. Iglesias; Anthus correndera, expert ID by C. Cicero 2009-02-12 based on morphology"'
  },
  {
    name: 'associatedMedia',
    qualName: 'http://rs.tdwg.org/dwc/terms/associatedMedia',
    description: 'A list (concatenated and separated) of identifiers (publication, global unique identifier, URI) of media associated with the Occurrence.',
    examples: '"http://arctos.database.museum/SpecimenImages/UAMObs/Mamm/2/P7291179.JPG"'
  },
  {
    name: 'associatedReferences',
    qualName: 'http://rs.tdwg.org/dwc/terms/associatedReferences',
    description: 'A list (concatenated and separated) of identifiers (publication, bibliographic reference, global unique identifier, URI) of literature associated with the Occurrence.',
    examples: '"http://www.sciencemag.org/cgi/content/abstract/322/5899/261", "Christopher J. Conroy, Jennifer L. Neuwald. 2008. Phylogeographic study of the California vole, Microtus californicus Journal of Mammalogy, 89(3):755-767."'
  },
  {
    name: 'associatedOccurrences',
    qualName: 'http://rs.tdwg.org/dwc/terms/associatedOccurrences',
    description: 'A list (concatenated and separated) of identifiers of other Occurrence records and their associations to this Occurrence.',
    examples: '"sibling of FMNH:Mammal:1234; sibling of FMNH:Mammal:1235"'
  },
  {
    name: 'associatedSequences',
    qualName: 'http://rs.tdwg.org/dwc/terms/associatedSequences',
    description: 'A list (concatenated and separated) of identifiers (publication, global unique identifier, URI) of genetic sequence information associated with the Occurrence.',
    examples: '"GenBank: U34853.1"'
  },
  {
    name: 'associatedTaxa',
    qualName: 'http://rs.tdwg.org/dwc/terms/associatedTaxa',
    description: 'A list (concatenated and separated) of identifiers or names of taxa and their associations with the Occurrence.',
    examples: '"host: Quercus alba"'
  },
  {
    name: 'occurrenceDetails',
    qualName: 'http://rs.tdwg.org/dwc/terms/occurrenceDetails',
    description: 'This term is deprecated in favor over the new dcterm:references. Previously this term was used as: A reference (publication, URI) to the most detailed information available about the Occurrence.',
    examples: ''
  },
  {
    name: 'eventID',
    qualName: 'http://rs.tdwg.org/dwc/terms/eventID',
    description: 'An identifier for the set of information associated with an Event (something that occurs at a place and time). May be a global unique identifier or an identifier specific to the data set.',
    examples: ''
  },
  {
    name: 'samplingProtocol',
    qualName: 'http://rs.tdwg.org/dwc/terms/samplingProtocol',
    description: 'The name of, reference to, or description of the method or protocol used during an Event.',
    examples: '"UV light trap", "mist net", "bottom trawl", "ad hoc observation", "point count", "Penguins from space: faecal stains reveal the location of emperor penguin colonies, http://dx.doi.org/10.1111/j.1466-8238.2009.00467.x", "Takats et al. 2001. Guidelines for Nocturnal Owl Monitoring in North America. Beaverhill Bird Observatory and Bird Studies Canada, Edmonton, Alberta. 32 pp.", "http://www.bsc-eoc.org/download/Owl.pdf"'
  },
  {
    name: 'samplingEffort',
    qualName: 'http://rs.tdwg.org/dwc/terms/samplingEffort',
    description: 'The amount of effort expended during an Event.',
    examples: '"40 trap-nights", "10 observer-hours; 10 km by foot; 30 km by car"'
  },
  {
    name: 'eventDate',
    qualName: 'http://rs.tdwg.org/dwc/terms/eventDate',
    description: 'The date-time or interval during which an Event occurred. For occurrences, this is the date-time when the event was recorded. Not suitable for a time in a geological context. Recommended best practice is to use an encoding scheme, such as ISO 8601:2004(E).',
    examples: '"1963-03-08T14:07-0600" is 8 Mar 1963 2:07pm in the time zone six hours earlier than UTC, "2009-02-20T08:40Z" is 20 Feb 2009 8:40am UTC, "1809-02-12" is 12 Feb 1809, "1906-06" is Jun 1906, "1971" is just that year, "2007-03-01T13:00:00Z/2008-05-11T15:30:00Z" is the interval between 1 Mar 2007 1pm UTC and 11 May 2008 3:30pm UTC, "2007-11-13/15" is the interval between 13 Nov 2007 and 15 Nov 2007.'
  },
  {
    name: 'eventTime',
    qualName: 'http://rs.tdwg.org/dwc/terms/eventTime',
    description: 'The time or interval during which an Event occurred. Recommended best practice is to use an encoding scheme, such as ISO 8601:2004(E).',
    examples: '"14:07-0600" is 2:07pm in the time zone six hours earlier than UTC, "08:40:21Z" is 8:40:21am UTC, "13:00:00Z/15:30:00Z" is the interval between 1pm UTC and 3:30pm UTC.'
  },
  {
    name: 'startDayOfYear',
    qualName: 'http://rs.tdwg.org/dwc/terms/startDayOfYear',
    description: 'The earliest ordinal day of the year on which the Event occurred (1 for January 1, 365 for December 31, except in a leap year, in which case it is 366).',
    examples: '"1" (=1 Jan), "366" (=31 Dec), "365" (=30 Dec in a leap year, 31 Dec in a non-leap year)'
  },
  {
    name: 'endDayOfYear',
    qualName: 'http://rs.tdwg.org/dwc/terms/endDayOfYear',
    description: 'The latest ordinal day of the year on which the Event occurred (1 for January 1, 365 for December 31, except in a leap year, in which case it is 366).',
    examples: '"1" (=1 Jan), "366" (=31 Dec), "365" (=30 Dec in a leap year, 31 Dec in a non-leap year)'
  },
  {
    name: 'year',
    qualName: 'http://rs.tdwg.org/dwc/terms/year',
    description: 'The four-digit year in which the Event occurred, according to the Common Era Calendar.',
    examples: '"2008"'
  },
  {
    name: 'month',
    qualName: 'http://rs.tdwg.org/dwc/terms/month',
    description: 'The ordinal month in which the Event occurred.',
    examples: '"1" (=January), "10" (=October)'
  },
  {
    name: 'day',
    qualName: 'http://rs.tdwg.org/dwc/terms/day',
    description: 'The integer day of the month on which the Event occurred.',
    examples: '"9", "28"'
  },
  {
    name: 'verbatimEventDate',
    qualName: 'http://rs.tdwg.org/dwc/terms/verbatimEventDate',
    description: 'The verbatim original representation of the date and time information for an Event.',
    examples: '"spring 1910", "Marzo 2002", "1999-03-XX", "17IV1934"'
  },
  {
    name: 'habitat',
    qualName: 'http://rs.tdwg.org/dwc/terms/habitat',
    description: 'A category or description of the habitat in which the Event occurred.',
    examples: '"oak savanna", "pre-cordilleran steppe"'
  },
  {
    name: 'fieldNumber',
    qualName: 'http://rs.tdwg.org/dwc/terms/fieldNumber',
    description: 'An identifier given to the event in the field. Often serves as a link between field notes and the Event.',
    examples: '"RV Sol 87-03-08"'
  },
  {
    name: 'fieldNotes',
    qualName: 'http://rs.tdwg.org/dwc/terms/fieldNotes',
    description: 'One of a) an indicator of the existence of, b) a reference to (publication, URI), or c) the text of notes taken in the field about the Event.',
    examples: '"notes available in Grinnell-Miller Library"'
  },
  {
    name: 'eventRemarks',
    qualName: 'http://rs.tdwg.org/dwc/terms/eventRemarks',
    description: 'Comments or notes about the Event.',
    examples: '"after the recent rains the river is nearly at flood stage"'
  },
  {
    name: 'locationID',
    qualName: 'http://rs.tdwg.org/dwc/terms/locationID',
    description: 'An identifier for the set of location information (data associated with dcterms:Location). May be a global unique identifier or an identifier specific to the data set.',
    examples: ''
  },
  {
    name: 'higherGeographyID',
    qualName: 'http://rs.tdwg.org/dwc/terms/higherGeographyID',
    description: 'An identifier for the geographic region within which the Location occurred. Recommended best practice is to use an persistent identifier from a controlled vocabulary such as the Getty Thesaurus of Geographic Names.',
    examples: '"TGN: 1002002" for Prov. Tierra del Fuego, Argentina'
  },
  {
    name: 'higherGeography',
    qualName: 'http://rs.tdwg.org/dwc/terms/higherGeography',
    description: 'A list (concatenated and separated) of geographic names less specific than the information captured in the locality term.',
    examples: '"South America; Argentina; Patagonia; Parque Nacional Nahuel Huapi; Neuquén; Los Lagos" with accompanying values "South America" in Continent, "Argentina" in Country, "Neuquén" in StateProvince, and Los Lagos in County.'
  },
  {
    name: 'continent',
    qualName: 'http://rs.tdwg.org/dwc/terms/continent',
    description: 'The name of the continent in which the Location occurs. Recommended best practice is to use a controlled vocabulary such as the Getty Thesaurus of Geographic Names or the ISO 3166 Continent code.',
    examples: '"Antarctica"'
  },
  {
    name: 'waterBody',
    qualName: 'http://rs.tdwg.org/dwc/terms/waterBody',
    description: 'The name of the water body in which the Location occurs. Recommended best practice is to use a controlled vocabulary such as the Getty Thesaurus of Geographic Names.',
    examples: '"Indian Ocean", "Baltic Sea"'
  },
  {
    name: 'islandGroup',
    qualName: 'http://rs.tdwg.org/dwc/terms/islandGroup',
    description: 'The name of the island group in which the Location occurs. Recommended best practice is to use a controlled vocabulary such as the Getty Thesaurus of Geographic Names.',
    examples: '"Alexander Archipelago"'
  },
  {
    name: 'island',
    qualName: 'http://rs.tdwg.org/dwc/terms/island',
    description: 'The name of the island on or near which the Location occurs. Recommended best practice is to use a controlled vocabulary such as the Getty Thesaurus of Geographic Names.',
    examples: '"Isla Victoria"'
  },
  {
    name: 'country',
    qualName: 'http://rs.tdwg.org/dwc/terms/country',
    description: 'The name of the country or major administrative unit in which the Location occurs. Recommended best practice is to use a controlled vocabulary such as the Getty Thesaurus of Geographic Names.',
    examples: '"Denmark", "Colombia", "España"'
  },
  {
    name: 'countryCode',
    qualName: 'http://rs.tdwg.org/dwc/terms/countryCode',
    description: 'The standard code for the country in which the Location occurs. Recommended best practice is to use ISO 3166-1-alpha-2 country codes.',
    examples: '"AR" for Argentina, "SV" for El Salvador'
  },
  {
    name: 'stateProvince',
    qualName: 'http://rs.tdwg.org/dwc/terms/stateProvince',
    description: 'The name of the next smaller administrative region than country (state, province, canton, department, region, etc.) in which the Location occurs.',
    examples: '"Montana", "Minas Gerais", "Córdoba"'
  },
  {
    name: 'county',
    qualName: 'http://rs.tdwg.org/dwc/terms/county',
    description: 'The full, unabbreviated name of the next smaller administrative region than stateProvince (county, shire, department, etc.) in which the Location occurs.',
    examples: '"Missoula", "Los Lagos", "Mataró"'
  },
  {
    name: 'municipality',
    qualName: 'http://rs.tdwg.org/dwc/terms/municipality',
    description: 'The full, unabbreviated name of the next smaller administrative region than county (city, municipality, etc.) in which the Location occurs. Do not use this term for a nearby named place that does not contain the actual location.',
    examples: '"Holzminden"'
  },
  {
    name: 'locality',
    qualName: 'http://rs.tdwg.org/dwc/terms/locality',
    description: 'The specific description of the place. Less specific geographic information can be provided in other geographic terms (higherGeography, continent, country, stateProvince, county, municipality, waterBody, island, islandGroup). This term may contain information modified from the original to correct perceived errors or standardize the description.',
    examples: '"Bariloche, 25 km NNE via Ruta Nacional 40 (=Ruta 237)"'
  },
  {
    name: 'verbatimLocality',
    qualName: 'http://rs.tdwg.org/dwc/terms/verbatimLocality',
    description: 'The original textual description of the place.',
    examples: '"25 km NNE Bariloche por R. Nac. 237"'
  },
  {
    name: 'verbatimElevation',
    qualName: 'http://rs.tdwg.org/dwc/terms/verbatimElevation',
    description: 'The original description of the elevation (altitude, usually above sea level) of the Location.',
    examples: '"100-200 m"'
  },
  {
    name: 'minimumElevationInMeters',
    qualName: 'http://rs.tdwg.org/dwc/terms/minimumElevationInMeters',
    description: 'The lower limit of the range of elevation (altitude, usually above sea level), in meters.',
    examples: '"100"'
  },
  {
    name: 'maximumElevationInMeters',
    qualName: 'http://rs.tdwg.org/dwc/terms/maximumElevationInMeters',
    description: 'The upper limit of the range of elevation (altitude, usually above sea level), in meters.',
    examples: '"200"'
  },
  {
    name: 'verbatimDepth',
    qualName: 'http://rs.tdwg.org/dwc/terms/verbatimDepth',
    description: 'The original description of the depth below the local surface.',
    examples: '"100-200 m"'
  },
  {
    name: 'minimumDepthInMeters',
    qualName: 'http://rs.tdwg.org/dwc/terms/minimumDepthInMeters',
    description: 'The lesser depth of a range of depth below the local surface, in meters.',
    examples: '"100"'
  },
  {
    name: 'maximumDepthInMeters',
    qualName: 'http://rs.tdwg.org/dwc/terms/maximumDepthInMeters',
    description: 'The greater depth of a range of depth below the local surface, in meters.',
    examples: '"200"'
  },
  {
    name: 'minimumDistanceAboveSurfaceInMeters',
    qualName: 'http://rs.tdwg.org/dwc/terms/minimumDistanceAboveSurfaceInMeters',
    description: 'The lesser distance in a range of distance from a reference surface in the vertical direction, in meters. Use positive values for locations above the surface, negative values for locations below. If depth measures are given, the reference surface is the location given by the depth, otherwise the reference surface is the location given by the elevation.',
    examples: '1.5 meter sediment core from the bottom of a lake (at depth 20m) at 300m elevation; VerbatimElevation: "300m" MinimumElevationInMeters: "300", MaximumElevationInMeters: "300", VerbatimDepth: "20m", MinimumDepthInMeters: "20", MaximumDepthInMeters: "20", minimumDistanceAboveSurfaceInMeters: "0", maximumDistanceAboveSurfaceInMeters: "-1.5"'
  },
  {
    name: 'maximumDistanceAboveSurfaceInMeters',
    qualName: 'http://rs.tdwg.org/dwc/terms/maximumDistanceAboveSurfaceInMeters',
    description: 'The greater distance in a range of distance from a reference surface in the vertical direction, in meters. Use positive values for locations above the surface, negative values for locations below. If depth measures are given, the reference surface is the location given by the depth, otherwise the reference surface is the location given by the elevation.',
    examples: '1.5 meter sediment core from the bottom of a lake (at depth 20m) at 300m elevation; VerbatimElevation: "300m" MinimumElevationInMeters: "300", MaximumElevationInMeters: "300", VerbatimDepth: "20m", MinimumDepthInMeters: "20", MaximumDepthInMeters: "20", minimumDistanceAboveSurfaceInMeters: "0", maximumDistanceAboveSurfaceInMeters: "-1.5"'
  },
  {
    name: 'locationAccordingTo',
    qualName: 'http://rs.tdwg.org/dwc/terms/locationAccordingTo',
    description: 'Information about the source of this Location information. Could be a publication (gazetteer), institution, or team of individuals.',
    examples: '"Getty Thesaurus of Geographic Names", "GADM"'
  },
  {
    name: 'locationRemarks',
    qualName: 'http://rs.tdwg.org/dwc/terms/locationRemarks',
    description: 'Comments or notes about the Location.',
    examples: '"under water since 2005"'
  },
  {
    name: 'verbatimCoordinates',
    qualName: 'http://rs.tdwg.org/dwc/terms/verbatimCoordinates',
    description: 'The verbatim original spatial coordinates of the Location. The coordinate ellipsoid, geodeticDatum, or full Spatial Reference System (SRS) for these coordinates should be stored in verbatimSRS and the coordinate system should be stored in verbatimCoordinateSystem.',
    examples: '"41 05 54S 121 05 34W", "17T 630000 4833400"'
  },
  {
    name: 'verbatimLatitude',
    qualName: 'http://rs.tdwg.org/dwc/terms/verbatimLatitude',
    description: 'The verbatim original latitude of the Location. The coordinate ellipsoid, geodeticDatum, or full Spatial Reference System (SRS) for these coordinates should be stored in verbatimSRS and the coordinate system should be stored in verbatimCoordinateSystem.',
    examples: '"41 05 54.03S"'
  },
  {
    name: 'verbatimLongitude',
    qualName: 'http://rs.tdwg.org/dwc/terms/verbatimLongitude',
    description: 'The verbatim original longitude of the Location. The coordinate ellipsoid, geodeticDatum, or full Spatial Reference System (SRS) for these coordinates should be stored in verbatimSRS and the coordinate system should be stored in verbatimCoordinateSystem.',
    examples: "\"121d 10' 34\" W\""
  },
  {
    name: 'verbatimCoordinateSystem',
    qualName: 'http://rs.tdwg.org/dwc/terms/verbatimCoordinateSystem',
    description: 'The spatial coordinate system for the verbatimLatitude and verbatimLongitude or the verbatimCoordinates of the Location. Recommended best practice is to use a controlled vocabulary.',
    examples: '"decimal degrees", "degrees decimal minutes", "degrees minutes seconds", "UTM"'
  },
  {
    name: 'verbatimSRS',
    qualName: 'http://rs.tdwg.org/dwc/terms/verbatimSRS',
    description: 'The ellipsoid, geodetic datum, or spatial reference system (SRS) upon which coordinates given in verbatimLatitude and verbatimLongitude, or verbatimCoordinates are based. Recommended best practice is use the EPSG code as a controlled vocabulary to provide an SRS, if known. Otherwise use a controlled vocabulary for the name or code of the geodetic datum, if known. Otherwise use a controlled vocabulary for the name or code of the ellipsoid, if known. If none of these is known, use the value "unknown".',
    examples: '"EPSG:4326", "WGS84", "NAD27", "Campo Inchauspe", "European 1950", "Clarke 1866"'
  },
  {
    name: 'decimalLatitude',
    qualName: 'http://rs.tdwg.org/dwc/terms/decimalLatitude',
    description: 'The geographic latitude (in decimal degrees, using the spatial reference system given in geodeticDatum) of the geographic center of a Location. Positive values are north of the Equator, negative values are south of it. Legal values lie between -90 and 90, inclusive.',
    examples: '"-41.0983423"'
  },
  {
    name: 'decimalLongitude',
    qualName: 'http://rs.tdwg.org/dwc/terms/decimalLongitude',
    description: 'The geographic longitude (in decimal degrees, using the spatial reference system given in geodeticDatum) of the geographic center of a Location. Positive values are east of the Greenwich Meridian, negative values are west of it. Legal values lie between -180 and 180, inclusive.',
    examples: '"-121.1761111"'
  },
  {
    name: 'geodeticDatum',
    qualName: 'http://rs.tdwg.org/dwc/terms/geodeticDatum',
    description: 'The ellipsoid, geodetic datum, or spatial reference system (SRS) upon which the geographic coordinates given in decimalLatitude and decimalLongitude as based. Recommended best practice is use the EPSG code as a controlled vocabulary to provide an SRS, if known. Otherwise use a controlled vocabulary for the name or code of the geodetic datum, if known. Otherwise use a controlled vocabulary for the name or code of the ellipsoid, if known. If none of these is known, use the value "unknown".',
    examples: '"EPSG:4326", "WGS84", "NAD27", "Campo Inchauspe", "European 1950", "Clarke 1866"'
  },
  {
    name: 'coordinateUncertaintyInMeters',
    qualName: 'http://rs.tdwg.org/dwc/terms/coordinateUncertaintyInMeters',
    description: 'The horizontal distance (in meters) from the given decimalLatitude and decimalLongitude describing the smallest circle containing the whole of the Location. Leave the value empty if the uncertainty is unknown, cannot be estimated, or is not applicable (because there are no coordinates). Zero is not a valid value for this term.',
    examples: '"30" (reasonable lower limit of a GPS reading under good conditions if the actual precision was not recorded at the time), "71" (uncertainty for a UTM coordinate having 100 meter precision and a known spatial reference system).'
  },
  {
    name: 'coordinatePrecision',
    qualName: 'http://rs.tdwg.org/dwc/terms/coordinatePrecision',
    description: 'A decimal representation of the precision of the coordinates given in the decimalLatitude and decimalLongitude.',
    examples: '"0.00001" (normal GPS limit for decimal degrees), "0.000278" (nearest second), "0.01667" (nearest minute), "1.0" (nearest degree)'
  },
  {
    name: 'pointRadiusSpatialFit',
    qualName: 'http://rs.tdwg.org/dwc/terms/pointRadiusSpatialFit',
    description: 'The ratio of the area of the point-radius (decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters) to the area of the true (original, or most specific) spatial representation of the Location. Legal values are 0, greater than or equal to 1, or undefined. A value of 1 is an exact match or 100% overlap. A value of 0 should be used if the given point-radius does not completely contain the original representation. The pointRadiusSpatialFit is undefined (and should be left blank) if the original representation is a point without uncertainty and the given georeference is not that same point (without uncertainty). If both the original and the given georeference are the same point, the pointRadiusSpatialFit is 1.',
    examples: 'Detailed explanations with graphical examples can be found in the "Guide to Best Practices for Georeferencing", Chapman and Wieczorek, eds. 2006 (http://www.gbif.org/prog/digit/Georeferencing).'
  },
  {
    name: 'footprintWKT',
    qualName: 'http://rs.tdwg.org/dwc/terms/footprintWKT',
    description: 'A Well-Known Text (WKT) representation of the shape (footprint, geometry) that defines the Location. A Location may have both a point-radius representation (see decimalLatitude) and a footprint representation, and they may differ from each other.',
    examples: 'the one-degree bounding box with opposite corners at (longitude=10, latitude=20) and (longitude=11, latitude=21) would be expressed in well-known text as POLYGON ((10 20, 11 20, 11 21, 10 21, 10 20))'
  },
  {
    name: 'footprintSRS',
    qualName: 'http://rs.tdwg.org/dwc/terms/footprintSRS',
    description: 'A Well-Known Text (WKT) representation of the Spatial Reference System (SRS) for the footprintWKT of the Location. Do not use this term to describe the SRS of the decimalLatitude and decimalLongitude, even if it is the same as for the footprintWKT - use the geodeticDatum instead.',
    examples: 'The WKT for the standard WGS84 SRS (EPSG:4326) is "GEOGCS["GCS_WGS_1984",DATUM["D_WGS_1984",SPHEROID["WGS_1984",6378137,298.257223563]],PRIMEM["Greenwich",0],UNIT["Degree",0.0174532925199433]]" without the enclosing quotes.'
  },
  {
    name: 'footprintSpatialFit',
    qualName: 'http://rs.tdwg.org/dwc/terms/footprintSpatialFit',
    description: 'The ratio of the area of the footprint (footprintWKT) to the area of the true (original, or most specific) spatial representation of the Location. Legal values are 0, greater than or equal to 1, or undefined. A value of 1 is an exact match or 100% overlap. A value of 0 should be used if the given footprint does not completely contain the original representation. The footprintSpatialFit is undefined (and should be left blank) if the original representation is a point and the given georeference is not that same point. If both the original and the given georeference are the same point, the footprintSpatialFit is 1.',
    examples: 'Detailed explanations with graphical examples can be found in the "Guide to Best Practices for Georeferencing", Chapman and Wieczorek, eds. 2006 (http://www.gbif.org/prog/digit/Georeferencing).'
  },
  {
    name: 'georeferencedBy',
    qualName: 'http://rs.tdwg.org/dwc/terms/georeferencedBy',
    description: 'A list (concatenated and separated) of names of people, groups, or organizations who determined the georeference (spatial representation) the Location.',
    examples: '"Kristina Yamamoto (MVZ); Janet Fang (MVZ)", "Brad Millen (ROM)"'
  },
  {
    name: 'georeferencedDate',
    qualName: 'http://rs.tdwg.org/dwc/terms/georeferencedDate',
    description: 'The date on which the Location was georeferenced. Recommended best practice is to use an encoding scheme, such as ISO 8601:2004(E).',
    examples: '1963-03-08'
  },
  {
    name: 'georeferenceProtocol',
    qualName: 'http://rs.tdwg.org/dwc/terms/georeferenceProtocol',
    description: 'A description or reference to the methods used to determine the spatial footprint, coordinates, and uncertainties.',
    examples: '"Guide to Best Practices for Georeferencing" (Chapman and Wieczorek, eds. 2006), Global Biodiversity Information Facility.", "MaNIS/HerpNet/ORNIS Georeferencing Guidelines", "BioGeomancer"'
  },
  {
    name: 'georeferenceSources',
    qualName: 'http://rs.tdwg.org/dwc/terms/georeferenceSources',
    description: 'A list (concatenated and separated) of maps, gazetteers, or other resources used to georeference the Location, described specifically enough to allow anyone in the future to use the same resources.',
    examples: '"USGS 1:24000 Florence Montana Quad; Terrametrics 2008 on Google Earth"'
  },
  {
    name: 'georeferenceVerificationStatus',
    qualName: 'http://rs.tdwg.org/dwc/terms/georeferenceVerificationStatus',
    description: 'A categorical description of the extent to which the georeference has been verified to represent the best possible spatial description. Recommended best practice is to use a controlled vocabulary.',
    examples: '"requires verification", "verified by collector", "verified by curator".'
  },
  {
    name: 'georeferenceRemarks',
    qualName: 'http://rs.tdwg.org/dwc/terms/georeferenceRemarks',
    description: 'Notes or comments about the spatial description determination, explaining assumptions made in addition or opposition to the those formalized in the method referred to in georeferenceProtocol.',
    examples: '"assumed distance by road (Hwy. 101)"'
  },
  {
    name: 'geologicalContextID',
    qualName: 'http://rs.tdwg.org/dwc/terms/geologicalContextID',
    description: 'An identifier for the set of information associated with a GeologicalContext (the location within a geological context, such as stratigraphy). May be a global unique identifier or an identifier specific to the data set.',
    examples: ''
  },
  {
    name: 'earliestEonOrLowestEonothem',
    qualName: 'http://rs.tdwg.org/dwc/terms/earliestEonOrLowestEonothem',
    description: 'The full name of the earliest possible geochronologic eon or lowest chrono-stratigraphic eonothem or the informal name ("Precambrian") attributable to the stratigraphic horizon from which the cataloged item was collected.',
    examples: '"Phanerozoic", "Proterozoic"'
  },
  {
    name: 'latestEonOrHighestEonothem',
    qualName: 'http://rs.tdwg.org/dwc/terms/latestEonOrHighestEonothem',
    description: 'The full name of the latest possible geochronologic eon or highest chrono-stratigraphic eonothem or the informal name ("Precambrian") attributable to the stratigraphic horizon from which the cataloged item was collected.',
    examples: '"Phanerozoic", "Proterozoic"'
  },
  {
    name: 'earliestEraOrLowestErathem',
    qualName: 'http://rs.tdwg.org/dwc/terms/earliestEraOrLowestErathem',
    description: 'The full name of the earliest possible geochronologic era or lowest chronostratigraphic erathem attributable to the stratigraphic horizon from which the cataloged item was collected.',
    examples: '"Cenozoic", "Mesozoic"'
  },
  {
    name: 'latestEraOrHighestErathem',
    qualName: 'http://rs.tdwg.org/dwc/terms/latestEraOrHighestErathem',
    description: 'The full name of the latest possible geochronologic era or highest chronostratigraphic erathem attributable to the stratigraphic horizon from which the cataloged item was collected.',
    examples: '"Cenozoic", "Mesozoic"'
  },
  {
    name: 'earliestPeriodOrLowestSystem',
    qualName: 'http://rs.tdwg.org/dwc/terms/earliestPeriodOrLowestSystem',
    description: 'The full name of the earliest possible geochronologic period or lowest chronostratigraphic system attributable to the stratigraphic horizon from which the cataloged item was collected.',
    examples: '"Neogene", "Tertiary", "Quaternary"'
  },
  {
    name: 'latestPeriodOrHighestSystem',
    qualName: 'http://rs.tdwg.org/dwc/terms/latestPeriodOrHighestSystem',
    description: 'The full name of the latest possible geochronologic period or highest chronostratigraphic system attributable to the stratigraphic horizon from which the cataloged item was collected.',
    examples: '"Neogene", "Tertiary", "Quaternary"'
  },
  {
    name: 'earliestEpochOrLowestSeries',
    qualName: 'http://rs.tdwg.org/dwc/terms/earliestEpochOrLowestSeries',
    description: 'The full name of the earliest possible geochronologic epoch or lowest chronostratigraphic series attributable to the stratigraphic horizon from which the cataloged item was collected.',
    examples: '"Holocene", "Pleistocene", "Ibexian Series"'
  },
  {
    name: 'latestEpochOrHighestSeries',
    qualName: 'http://rs.tdwg.org/dwc/terms/latestEpochOrHighestSeries',
    description: 'The full name of the latest possible geochronologic epoch or highest chronostratigraphic series attributable to the stratigraphic horizon from which the cataloged item was collected.',
    examples: '"Holocene", "Pleistocene", "Ibexian Series"'
  },
  {
    name: 'earliestAgeOrLowestStage',
    qualName: 'http://rs.tdwg.org/dwc/terms/earliestAgeOrLowestStage',
    description: 'The full name of the earliest possible geochronologic age or lowest chronostratigraphic stage attributable to the stratigraphic horizon from which the cataloged item was collected.',
    examples: '"Atlantic", "Boreal", "Skullrockian"'
  },
  {
    name: 'latestAgeOrHighestStage',
    qualName: 'http://rs.tdwg.org/dwc/terms/latestAgeOrHighestStage',
    description: 'The full name of the latest possible geochronologic age or highest chronostratigraphic stage attributable to the stratigraphic horizon from which the cataloged item was collected.',
    examples: '"Atlantic", "Boreal", "Skullrockian"'
  },
  {
    name: 'lowestBiostratigraphicZone',
    qualName: 'http://rs.tdwg.org/dwc/terms/lowestBiostratigraphicZone',
    description: 'The full name of the lowest possible geological biostratigraphic zone of the stratigraphic horizon from which the cataloged item was collected.',
    examples: ''
  },
  {
    name: 'highestBiostratigraphicZone',
    qualName: 'http://rs.tdwg.org/dwc/terms/highestBiostratigraphicZone',
    description: 'The full name of the highest possible geological biostratigraphic zone of the stratigraphic horizon from which the cataloged item was collected.',
    examples: ''
  },
  {
    name: 'lithostratigraphicTerms',
    qualName: 'http://rs.tdwg.org/dwc/terms/lithostratigraphicTerms',
    description: 'The combination of all litho-stratigraphic names for the rock from which the cataloged item was collected.',
    examples: ''
  },
  {
    name: 'group',
    qualName: 'http://rs.tdwg.org/dwc/terms/group',
    description: 'The full name of the lithostratigraphic group from which the cataloged item was collected.',
    examples: ''
  },
  {
    name: 'formation',
    qualName: 'http://rs.tdwg.org/dwc/terms/formation',
    description: 'The full name of the lithostratigraphic formation from which the cataloged item was collected.',
    examples: '"Notch Peak Fromation", "House Limestone", "Fillmore Formation"'
  },
  {
    name: 'member',
    qualName: 'http://rs.tdwg.org/dwc/terms/member',
    description: 'The full name of the lithostratigraphic member from which the cataloged item was collected.',
    examples: '"Lava Dam Member", "Hellnmaria Member"'
  },
  {
    name: 'bed',
    qualName: 'http://rs.tdwg.org/dwc/terms/bed',
    description: 'The full name of the lithostratigraphic bed from which the cataloged item was collected.',
    examples: ''
  },
  {
    name: 'identificationID',
    qualName: 'http://rs.tdwg.org/dwc/terms/identificationID',
    description: 'An identifier for the Identification (the body of information associated with the assignment of a scientific name). May be a global unique identifier or an identifier specific to the data set.',
    examples: ''
  },
  {
    name: 'identifiedBy',
    qualName: 'http://rs.tdwg.org/dwc/terms/identifiedBy',
    description: 'A list (concatenated and separated) of names of people, groups, or organizations who assigned the Taxon to the subject.',
    examples: '"James L. Patton", "Theodore Pappenfuss; Robert Macey"'
  },
  {
    name: 'dateIdentified',
    qualName: 'http://rs.tdwg.org/dwc/terms/dateIdentified',
    description: 'The date on which the subject was identified as representing the Taxon. Recommended best practice is to use an encoding scheme, such as ISO 8601:2004(E).',
    examples: '"1963-03-08T14:07-0600" is 8 Mar 1963 2:07pm in the time zone six hours earlier than UTC, "2009-02-20T08:40Z" is 20 Feb 2009 8:40am UTC, "1809-02-12" is 12 Feb 1809, "1906-06" is Jun 1906, "1971" is just that year, "2007-03-01T13:00:00Z/2008-05-11T15:30:00Z" is the interval between 1 Mar 2007 1pm UTC and 11 May 2008 3:30pm UTC, "2007-11-13/15" is the interval between 13 Nov 2007 and 15 Nov 2007.'
  },
  {
    name: 'identificationReferences',
    qualName: 'http://rs.tdwg.org/dwc/terms/identificationReferences',
    description: 'A list (concatenated and separated) of references (publication, global unique identifier, URI) used in the Identification.',
    examples: '"Aves del Noroeste Patagonico. Christie et al. 2004."'
  },
  {
    name: 'identificationRemarks',
    qualName: 'http://rs.tdwg.org/dwc/terms/identificationRemarks',
    description: 'Comments or notes about the Identification.',
    examples: '"Distinguished between Anthus correndera and Anthus hellmayri based on the comparative lengths of the uñas."'
  },
  {
    name: 'identificationQualifier',
    qualName: 'http://rs.tdwg.org/dwc/terms/identificationQualifier',
    description: "A brief phrase or a standard term (\"cf.\", \"aff.\") to express the determiner's doubts about the Identification.",
    examples: '1) For the determination "Quercus aff. agrifolia var. oxyadenia", identificationQualifier would be "aff. agrifolia var. oxyadenia" with accompanying values "Quercus" in genus, "agrifolia" in specificEpithet, "oxyadenia" in infraspecificEpithet, and "var." in rank. 2) For the determination "Quercus agrifolia cf. var. oxyadenia", identificationQualifier would be "cf. var. oxyadenia " with accompanying values "Quercus" in genus, "agrifolia" in specificEpithet, "oxyadenia" in infraspecificEpithet, and "var." in rank.'
  },
  {
    name: 'identificationVerificationStatus',
    qualName: 'http://rs.tdwg.org/dwc/terms/identificationVerificationStatus',
    description: 'A categorical indicator of the extent to which the taxonomic identification has been verified to be correct. Recommended best practice is to use a controlled vocabulary such as that used in HISPID/ABCD.',
    examples: '"0", "4"'
  },
  {
    name: 'typeStatus',
    qualName: 'http://rs.tdwg.org/dwc/terms/typeStatus',
    description: 'A list (concatenated and separated) of nomenclatural types (type status, typified scientific name, publication) applied to the subject.',
    examples: '"holotype of Ctenomys sociabilis. Pearson O. P., and M. I. Christie. 1985. Historia Natural, 5(37):388"'
  },
  {
    name: 'taxonID',
    qualName: 'http://rs.tdwg.org/dwc/terms/taxonID',
    description: 'An identifier for the set of taxon information (data associated with the Taxon class). May be a global unique identifier or an identifier specific to the data set.',
    examples: '"8fa58e08-08de-4ac1-b69c-1235340b7001", "32567", "http://species.gbif.org/abies_alba_1753", "urn:lsid:gbif.org:usages:32567"'
  },
  {
    name: 'scientificNameID',
    qualName: 'http://rs.tdwg.org/dwc/terms/scientificNameID',
    description: 'An identifier for the nomenclatural (not taxonomic) details of a scientific name.',
    examples: '"urn:lsid:ipni.org:names:37829-1:1.3"'
  },
  {
    name: 'acceptedNameUsageID',
    qualName: 'http://rs.tdwg.org/dwc/terms/acceptedNameUsageID',
    description: 'An identifier for the name usage (documented meaning of the name according to a source) of the currently valid (zoological) or accepted (botanical) taxon.',
    examples: '"8fa58e08-08de-4ac1-b69c-1235340b7001"'
  },
  {
    name: 'parentNameUsageID',
    qualName: 'http://rs.tdwg.org/dwc/terms/parentNameUsageID',
    description: 'An identifier for the name usage (documented meaning of the name according to a source) of the direct, most proximate higher-rank parent taxon (in a classification) of the most specific element of the scientificName.',
    examples: '"8fa58e08-08de-4ac1-b69c-1235340b7001"'
  },
  {
    name: 'originalNameUsageID',
    qualName: 'http://rs.tdwg.org/dwc/terms/originalNameUsageID',
    description: 'An identifier for the name usage (documented meaning of the name according to a source) in which the terminal element of the scientificName was originally established under the rules of the associated nomenclaturalCode.',
    examples: '"http://species.gbif.org/abies_alba_1753"'
  },
  {
    name: 'nameAccordingToID',
    qualName: 'http://rs.tdwg.org/dwc/terms/nameAccordingToID',
    description: 'An identifier for the source in which the specific taxon concept circumscription is defined or implied. See nameAccordingTo.',
    examples: '"doi:10.1016/S0269-915X(97)80026-2"'
  },
  {
    name: 'namePublishedInID',
    qualName: 'http://rs.tdwg.org/dwc/terms/namePublishedInID',
    description: 'An identifier for the publication in which the scientificName was originally established under the rules of the associated nomenclaturalCode.',
    examples: '"http://hdl.handle.net/10199/7"'
  },
  {
    name: 'taxonConceptID',
    qualName: 'http://rs.tdwg.org/dwc/terms/taxonConceptID',
    description: 'An identifier for the taxonomic concept to which the record refers - not for the nomenclatural details of a taxon.',
    examples: '"8fa58e08-08de-4ac1-b69c-1235340b7001"'
  },
  {
    name: 'scientificName',
    qualName: 'http://rs.tdwg.org/dwc/terms/scientificName',
    description: 'The full scientific name, with authorship and date information if known. When forming part of an Identification, this should be the name in lowest level taxonomic rank that can be determined. This term should not contain identification qualifications, which should instead be supplied in the IdentificationQualifier term.',
    examples: '"Coleoptera" (order), "Vespertilionidae" (family), "Manis" (genus), "Ctenomys sociabilis" (genus + specificEpithet), "Ambystoma tigrinum diaboli" (genus + specificEpithet + infraspecificEpithet), "Roptrocerus typographi (Györfi, 1952)" (genus + specificEpithet + scientificNameAuthorship), "Quercus agrifolia var. oxyadenia (Torr.) J.T. Howell" (genus + specificEpithet + taxonRank + infraspecificEpithet + scientificNameAuthorship)'
  },
  {
    name: 'acceptedNameUsage',
    qualName: 'http://rs.tdwg.org/dwc/terms/acceptedNameUsage',
    description: 'The full name, with authorship and date information if known, of the currently valid (zoological) or accepted (botanical) taxon.',
    examples: '"Tamias minimus" valid name for "Eutamias minimus"'
  },
  {
    name: 'parentNameUsage',
    qualName: 'http://rs.tdwg.org/dwc/terms/parentNameUsage',
    description: 'The full name, with authorship and date information if known, of the direct, most proximate higher-rank parent taxon (in a classification) of the most specific element of the scientificName.',
    examples: '"Rubiaceae", "Gruiformes", "Testudinae"'
  },
  {
    name: 'originalNameUsage',
    qualName: 'http://rs.tdwg.org/dwc/terms/originalNameUsage',
    description: 'The taxon name, with authorship and date information if known, as it originally appeared when first established under the rules of the associated nomenclaturalCode. The basionym (botany) or basonym (bacteriology) of the scientificName or the senior/earlier homonym for replaced names.',
    examples: '"Pinus abies", "Gasterosteus saltatrix Linnaeus 1768"'
  },
  {
    name: 'nameAccordingTo',
    qualName: 'http://rs.tdwg.org/dwc/terms/nameAccordingTo',
    description: 'The reference to the source in which the specific taxon concept circumscription is defined or implied - traditionally signified by the Latin "sensu" or "sec." (from secundum, meaning "according to"). For taxa that result from identifications, a reference to the keys, monographs, experts and other sources should be given.',
    examples: '"McCranie, J. R., D. B. Wake, and L. D. Wilson. 1996. The taxonomic status of Bolitoglossa schmidti, with comments on the biology of the Mesoamerican salamander Bolitoglossa dofleini (Caudata: Plethodontidae). Carib. J. Sci. 32:395-398.", "Werner Greuter 2008", "Lilljeborg 1861, Upsala Univ. Arsskrift, Math. Naturvet., pp. 4, 5"'
  },
  {
    name: 'namePublishedIn',
    qualName: 'http://rs.tdwg.org/dwc/terms/namePublishedIn',
    description: 'A reference for the publication in which the scientificName was originally established under the rules of the associated nomenclaturalCode.',
    examples: '"Pearson O. P., and M. I. Christie. 1985. Historia Natural, 5(37):388", "Forel, Auguste, Diagnosies provisoires de quelques espèces nouvelles de fourmis de Madagascar, récoltées par M. Grandidier., Annales de la Societe Entomologique de Belgique, Comptes-rendus des Seances 30, 1886"'
  },
  {
    name: 'namePublishedInYear',
    qualName: 'http://rs.tdwg.org/dwc/terms/namePublishedInYear',
    description: 'The four-digit year in which the scientificName was published.',
    examples: '1915'
  },
  {
    name: 'higherClassification',
    qualName: 'http://rs.tdwg.org/dwc/terms/higherClassification',
    description: 'A list (concatenated and separated) of taxa names terminating at the rank immediately superior to the taxon referenced in the taxon record. Recommended best practice is to order the list starting with the highest rank and separating the names for each rank with a semi-colon (";").',
    examples: '"Animalia; Chordata; Vertebrata; Mammalia; Theria; Eutheria; Rodentia; Hystricognatha; Hystricognathi; Ctenomyidae; Ctenomyini; Ctenomys"'
  },
  {
    name: 'kingdom',
    qualName: 'http://rs.tdwg.org/dwc/terms/kingdom',
    description: 'The full scientific name of the kingdom in which the taxon is classified.',
    examples: '"Animalia", "Plantae"'
  },
  {
    name: 'phylum',
    qualName: 'http://rs.tdwg.org/dwc/terms/phylum',
    description: 'The full scientific name of the phylum or division in which the taxon is classified.',
    examples: '"Chordata" (phylum), "Bryophyta" (division)'
  },
  {
    name: 'class',
    qualName: 'http://rs.tdwg.org/dwc/terms/class',
    description: 'The full scientific name of the class in which the taxon is classified.',
    examples: '"Mammalia", "Hepaticopsida"'
  },
  {
    name: 'order',
    qualName: 'http://rs.tdwg.org/dwc/terms/order',
    description: 'The full scientific name of the order in which the taxon is classified.',
    examples: '"Carnivora", "Monocleales"'
  },
  {
    name: 'family',
    qualName: 'http://rs.tdwg.org/dwc/terms/family',
    description: 'The full scientific name of the family in which the taxon is classified.',
    examples: '"Felidae", "Monocleaceae"'
  },
  {
    name: 'genus',
    qualName: 'http://rs.tdwg.org/dwc/terms/genus',
    description: 'The full scientific name of the genus in which the taxon is classified.',
    examples: '"Puma", "Monoclea"'
  },
  {
    name: 'subgenus',
    qualName: 'http://rs.tdwg.org/dwc/terms/subgenus',
    description: 'The full scientific name of the subgenus in which the taxon is classified. Values should include the genus to avoid homonym confusion.',
    examples: '"Strobus (Pinus)", "Puma (Puma)" "Loligo (Amerigo)", "Hieracium subgen. Pilosella"'
  },
  {
    name: 'specificEpithet',
    qualName: 'http://rs.tdwg.org/dwc/terms/specificEpithet',
    description: 'The name of the first or species epithet of the scientificName.',
    examples: '"concolor", "gottschei"'
  },
  {
    name: 'infraspecificEpithet',
    qualName: 'http://rs.tdwg.org/dwc/terms/infraspecificEpithet',
    description: 'The name of the lowest or terminal infraspecific epithet of the scientificName, excluding any rank designation.',
    examples: '"concolor", "oxyadenia", "sayi"'
  },
  {
    name: 'taxonRank',
    qualName: 'http://rs.tdwg.org/dwc/terms/taxonRank',
    description: 'The taxonomic rank of the most specific name in the scientificName. Recommended best practice is to use a controlled vocabulary.',
    examples: '"subspecies", "varietas", "forma", "species", "genus"'
  },
  {
    name: 'verbatimTaxonRank',
    qualName: 'http://rs.tdwg.org/dwc/terms/verbatimTaxonRank',
    description: 'The taxonomic rank of the most specific name in the scientificName as it appears in the original record.',
    examples: '"Agamospecies", "sub-lesus", "prole", "apomict", "nothogrex", "sp.", "subsp.", "var."'
  },
  {
    name: 'scientificNameAuthorship',
    qualName: 'http://rs.tdwg.org/dwc/terms/scientificNameAuthorship',
    description: 'The authorship information for the scientificName formatted according to the conventions of the applicable nomenclaturalCode.',
    examples: '"(Torr.) J.T. Howell", "(Martinovský) Tzvelev", "(Györfi, 1952)"'
  },
  {
    name: 'vernacularName',
    qualName: 'http://rs.tdwg.org/dwc/terms/vernacularName',
    description: 'A common or vernacular name.',
    examples: '"Andean Condor", "Condor Andino", "American Eagle", "Gänsegeier"'
  },
  {
    name: 'nomenclaturalCode',
    qualName: 'http://rs.tdwg.org/dwc/terms/nomenclaturalCode',
    description: 'The nomenclatural code (or codes in the case of an ambiregnal name) under which the scientificName is constructed. Recommended best practice is to use a controlled vocabulary.',
    examples: '"ICBN", "ICZN", "BC", "ICNCP", "BioCode", "ICZN; ICBN"'
  },
  {
    name: 'taxonomicStatus',
    qualName: 'http://rs.tdwg.org/dwc/terms/taxonomicStatus',
    description: 'The status of the use of the scientificName as a label for a taxon. Requires taxonomic opinion to define the scope of a taxon. Rules of priority then are used to define the taxonomic status of the nomenclature contained in that scope, combined with the experts opinion. It must be linked to a specific taxonomic reference that defines the concept. Recommended best practice is to use a controlled vocabulary.',
    examples: '"invalid", "misapplied", "homotypic synonym", "accepted"'
  },
  {
    name: 'nomenclaturalStatus',
    qualName: 'http://rs.tdwg.org/dwc/terms/nomenclaturalStatus',
    description: 'The status related to the original publication of the name and its conformance to the relevant rules of nomenclature. It is based essentially on an algorithm according to the business rules of the code.  It requires no taxonomic opinion.',
    examples: '"nom. ambig.", "nom. illeg.", "nom. subnud."'
  },
  {
    name: 'taxonRemarks',
    qualName: 'http://rs.tdwg.org/dwc/terms/taxonRemarks',
    description: 'Comments or notes about the taxon or name.',
    examples: '"this name is a misspelling in common use"'
  }
]
