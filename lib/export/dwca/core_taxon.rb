# Core Taxon class
# Repository URL: http://rs.gbif.org/core/dwc_taxon.xml

module Dwca::GbifProfile

  class CoreTaxon
    # taxonID (http://rs.tdwg.org/dwc/terms/taxonID)
    #
    # @return [String]
    # The unique identifier used for a name or taxon reference in the core
    # data file. Each row in the core data file has a unique taxonID and it
    # should be the first column in the data file. Synonyms occupy separate
    # lines and therefore also have unique taxonIDs. TaxonIDs may be
    # simple integers or more complex globally unique identifiers.
    #
    # Examples: 101; “8fa58e08-08de-4ac1-b69c-1235340b7001;
    attr_accessor :taxonID # [USED IN SF]
    
    # acceptedNameUsageID (http://rs.tdwg.org/dwc/terms/acceptedNameUsageID)
    #
    # @return [String]
    # This represents a second column in a synonym record that points to
    # the record representing the valid (zoological) or accepted (botanical)
    # name using the taxonID of that record as the “pointer.”
    #
    # Example: 8fa58e08-08de-4ac1-b69c-1235340b7001
    attr_accessor :acceptedNameUsageID # [USED IN SF]
    
    # acceptedNameUsage (http://rs.tdwg.org/dwc/terms/acceptedNameUsage)
    #
    # @return [String]
    # The scientificName of the taxon considered to be the valid
    # (zoological) or accepted (botanical) name for this nameUsage.
    #
    # Example: "Tamias minimus" valid name for "Eutamias minimus"
    attr_accessor :acceptedNameUsage

    # parentNameUsageID (http://rs.tdwg.org/dwc/terms/parentNameUsageID)
    #
    # @return [String]
    # The taxonID of the immediate higher-rank parent taxon (in a
    # classification). Using the ID is preferred over using the name (listed
    # as the next term).
    #
    # Example: “101” 8fa58e08-08de-4ac1-b69c-1235340b7001
    attr_accessor :parentNameUsageID # [USED IN SF]

    # parentNameUsage (http://rs.tdwg.org/dwc/terms/parentNameUsage)
    #
    # @return [String]
    # The scientificName of the immediate higher-rank parent taxon (in a
    # classification). This name must match the name used in the row
    # representing the parent taxon. Using IDs (using parentNameUsage) is
    # preferred to this method.
    #
    # Example: "Rubiaceae", "Gruiformes", "Testudinae"
    attr_accessor :parentNameUsage

    # originalNameUsageID (http://rs.tdwg.org/dwc/terms/originalNameUsageID)
    #
    # @return [String]
    # The taxonID of the record representing the name that was originally
    # established under the rules of the associated nomenclaturalCode (i.e.,
    # within the namePublishedIn reference). This may be known as the
    # basionym (botany) or basonym (bacteriology) of the scientificName or
    # the senior/earlier homonym for replaced names.
    #
    # Example: “101” 8fa58e08-08de-4ac1-b69c-1235340b7001
    attr_accessor :originalNameUsageID

    # originalNameUsage (http://rs.tdwg.org/dwc/terms/originalNameUsage)
    #
    # @return [String]
    # The equivalent of the scientificName as it originally appeared when
    # the name was first established under the rules of the associated
    # nomenclaturalCode (i.e., within the namePublishedIn reference). The
    # basionym (botany) or basonym (bacteriology) of the scientificName or
    # the senior/earlier homonym for replaced names.
    #
    # Example: "Pinus abies", "Gasterosteus saltatrix Linnaeus 1768"
    attr_accessor :originalNameUsage
    
    # nameAccordingTo (http://rs.tdwg.org/dwc/terms/nameAccordingTo)
    #
    # @return [String]
    # A bibliographic citation representing the concept or sense in which
    # the name is used. Traditionally, in botany, the Latin “sensu” or
    # “sec”. (for secundum – according to) have been used. For taxa that
    # result from identifications a reference to the keys used, monographs,
    # online source or experts should be given.
    #
    # Example: "Werner Greuter 2008; Lilljeborg 1861, Upsala Univ.
    # Arsskrift, Math. Naturvet., pp. 4, 5", "McCranie, J. R., D. B. Wake, 
    # and L. D. Wilson. 1996. The taxonomic status of Bolitoglossa schmidti,
    # with comments on the biology of the Mesoamerican salamander
    # Bolitoglossa dofleini (Caudata: Plethodontidae). Carib. J. Sci. 32:395-
    # 398."
    attr_accessor :nameAccordingTo

    # nameAccordingToID (http://rs.tdwg.org/dwc/terms/nameAccordingToID)
    #
    # @return [String]
    # A unique identifier that returns the details of a nameAccordingTo (see
    # above) reference.
    #
    # Example: “doi:10.1016/S0269-915X(97)80026-2”
    attr_accessor :nameAccordingToID

    # namePublishedIn (http://rs.tdwg.org/dwc/terms/namePublishedIn)
    #
    # @return [String]
    # Reference to a publication representing the original publication of the
    # name.
    #
    # Example: “Forel, Auguste, Diagnosies provisoires de quelques espèces
    # nouvelles de fourmis de Madagascar, récoltées par M. Grandidier.,
    # Annales de la Societe Entomologique de de Belgique, Comptes-rendus
    # des Seances 30, 1886”
    attr_accessor :namePublishedIn # [USED IN SF]

    # namePublishedInID (http://rs.tdwg.org/dwc/terms/namePublishedInID)
    #
    # @return [String]
    # A preferably resolvable, globally unique identifier that refers to
    # namePublishedIn.
    #
    # Example: http://hdl.handle.net/10199/7
    attr_accessor :namePublishedInID
    
    # scientificName (http://rs.tdwg.org/dwc/terms/scientificName)
    #
    # @return [String]
    # The scientific name of taxon with or without authorship information
    # depending on the format of the source database.
    #
    # Examples: "Coleoptera" , "Vespertilionidae”, "Manis" , "Ctenomys
    # sociabilis", "Ambystoma tigrinum diaboli", "Quercus agrifolia var.
    # oxyadenia (Torr.)"
    attr_accessor :scientificName # [USED IN SF]

    # scientificNameID (http://rs.tdwg.org/dwc/terms/scientificNameID)
    #
    # @return [String]
    # Exclusively used to reference an external and resolvable identifier
    # that returns nomenclatural (not taxonomic) details of a name. Use
    # taxonID to refer to taxa. Use to explicitly refer to an external
    # nomenclatural record.
    # Example: “urn:lsid:ipni.org:names:37829-1:1.3”
    attr_accessor :scientificNameID # [USED IN SF]
    
    # scientificNameAuthorship (http://rs.tdwg.org/dwc/terms/scientificNameAuthorship)
    #
    # @return [String]
    # The authorship information for the scientificName formatted
    # according to the conventions of the applicable nomenclaturalCode. If
    # authorship is included in the scientificName field, this field is
    # optional.
    #
    # Example: "(Torr.) J.T. Howell", "(Martinovsk ) Tzvelev", "(Linnaeus
    # 1768)"
    attr_accessor :scientificNameAuthorship # [USED IN SF]
    
    # higherClassification (http://rs.tdwg.org/dwc/terms/higherClassification)
    #
    # @return [String]
    # A list (concatenated and separated) of taxon names terminating at the
    # rank immediately superior to the taxon referenced in the taxon
    # record. This is used to fit the entire higher classification for a taxon
    # into a single field. Recommended best practice is to order the list
    # starting with the highest rank and separating the names for each rank
    # with a semi-colon (";").
    #
    # Example:
    # “Animalia;Chordata;Vertebrata;Mammalia;Theria;Eutheria;Rodentia;Hystricognatha;Hystricognathi;Ctenomyidae;Ctenomyini;Ctenomys”
    attr_accessor :higherClassification

    # kingdom (http://rs.tdwg.org/dwc/terms/kingdom)
    #
    # @return [String]
    # The full scientific name of the kingdom in which the taxon is
    # classified.
    #
    # Example: "Animalia", "Plantae"
    attr_accessor :kingdom
    
    # phylum (http://rs.tdwg.org/dwc/terms/phylum)
    #
    # @return [String]
    # The full scientific name of the phylum in which the taxon is classified.
    #
    # Example: "Chordata" (phylum), "Bryophyta" (division)
    attr_accessor :phylum
    
    # (klass) class (http://rs.tdwg.org/dwc/terms/class)
    #
    # @return [String]
    # The full scientific name of the class in which the taxon is classified.
    #
    # Example: "Mammalia", "Hepaticopsida"
    attr_accessor :klass

    # order (http://rs.tdwg.org/dwc/terms/order)
    #
    # @return [String]
    # The full scientific name of the order in which the taxon is classified.
    #
    # Example: "Carnivora", "Monocleales"
    attr_accessor :order
    
    # family (http://rs.tdwg.org/dwc/terms/family)
    #
    # @return [String]
    # The full scientific name of the family in which the taxon is classified.
    #
    # Example: "Felidae", "Monocleaceae"
    attr_accessor :family
    
    # genus (http://rs.tdwg.org/dwc/terms/genus)
    #
    # @return [String]
    # The full scientific name of the genus in which the taxon is classified.
    #
    # Example: "Puma", "Monoclea"
    attr_accessor :genus
    
    # subgenus (http://rs.tdwg.org/dwc/terms/subgenus)
    #
    # @return [String]
    # The full scientific name of the subgenus in which the taxon is
    # classified. Values should include the genus to avoid homonym
    # confusion.
    #
    # Example: Puma (Puma); Loligo (Amerigo); Hieracium subgen. Pilosella
    attr_accessor :subgenus

    # specificEpithet (http://rs.tdwg.org/dwc/terms/specificEpithet)
    #
    # @return [String]
    # The name of the species epithet of the scientificName.
    #
    # Example: "concolor", "gottschei"
    attr_accessor :specificEpithet
    
    # infraspecificEpithet (http://rs.tdwg.org/dwc/terms/infraspecificEpithet)
    #
    # @return [String]
    # The name of the lowest or terminal infraspecific epithet of the
    # scientificName, excluding any rank marker.
    #
    # Example: "concolor", "oxyadenia", "sayi"
    attr_accessor :infraspecificEpithet
    
    # taxonRank (http://rs.tdwg.org/dwc/terms/taxonRank)
    #
    # @return [String]
    # The taxonomic rank of the most specific name in the scientificName.
    #
    # Recommended vocabulary: http://rs.gbif.org/vocabulary/gbif/rank.xml
    #
    # Example: "subspecies", "varietas", "forma", "species", "genus"
    attr_accessor :taxonRank # [USED IN SF]

    # verbatimTaxonRank (http://rs.tdwg.org/dwc/terms/verbatimTaxonRank)
    #
    # @return [String]
    # The taxonomic rank of the most specific name in the scientificName
    # as it appears in the original record or the rank designator within the
    # verbatim original name itself. May incude abbreviations for example.
    #
    # Example: "Agamospecies", "sub-lesus", "prole", "apomict", "nothogrex",
    # "sp.", "subsp.", "var."
    attr_accessor :verbatimTaxonRank
    
    # @!attribute vernacularName 
    # vernacularName (http://rs.tdwg.org/dwc/terms/vernacularName)
    #
    # @raise [NoMethodError] (This information is provided in the vernaculars extension)
    # A common or vernacular name. Use this in the core file when there is
    # only a single common name to share per taxon record.
    #
    # Example: "Andean Condor", "Condor Andino", "American Eagle",
    # "Gänsegeier"
    
    # nomenclaturalCode (http://rs.tdwg.org/dwc/terms/nomenclaturalCode)
    #
    # @return [String]
    # The nomenclatural code under which the scientificName is
    # constructed.
    #
    # Vocabulary: http://rs.gbif.org/vocabulary/gbif/nomenclatural_code.xml
    #
    # Example: ICBN; ICZN
    attr_accessor :nomenclaturalCode # [USED IN SF (in meta.xml)]
    
    # taxonomicStatus (http://rs.tdwg.org/dwc/terms/taxonomicStatus)
    #
    # @return [String]
    # The status of the use of the scientificName as a label for a taxon.
    # Requires taxonomic opinion to define the scope of a taxon. Rules of
    # priority then are used to define the taxonomic status of the
    # nomenclature contained in that scope, combined with the experts
    # opinion. It must be linked to a specific taxonomic reference that
    # defines the concept.
    #
    # Recommended vocabulary: http://rs.gbif.org/vocabulary/gbif/taxonomic_status.xml
    #
    # Example: "invalid", "misapplied", "homotypic synonym", "accepted"
    attr_accessor :taxonomicStatus # [USED IN SF]

    # nomenclaturalStatus (http://rs.tdwg.org/dwc/terms/nomenclaturalStatus)
    #
    # @return [String]
    # The status related to the original publication of the name and its
    # conformance to the relevant rules of nomenclature. It is based
    # essentially on an algorithm according to the business rules of the
    # code. It requires no taxonomic opinion.
    #
    # Recommended vocabulary: http://rs.gbif.org/vocabulary/gbif/nomenclatural_status.xml
    #
    # Example: "nom. ambig.", "nom. illeg.", "nom. subnud."
    attr_accessor :nomenclaturalStatus # [USED IN SF]

    # taxonRemarks (http://rs.tdwg.org/dwc/terms/taxonRemarks)
    #
    # @return [String]
    # Comments or notes about the taxon or name.
    #
    # Example: “Type consists of a skull and skeletal fragments”.
    attr_accessor :taxonRemarks # [USED IN SF]

    # modified (http://purl.org/dc/terms/modified)
    #
    # @return [String]
    # Date when the record was last updated
    #
    # Example: “2009-08-21”
    attr_accessor :modified # [USED IN SF]
    
    # language (http://purl.org/dc/terms/language)
    #
    # @return [String]
    # The language of the parent resource. Recommended best practice is
    # to use a controlled vocabulary such as ISO 693
    #
    # Example: "eng"
    attr_accessor :language
    
    # rights (http://purl.org/dc/terms/rights)
    #
    # @return [String]
    # Information about rights held in and over the resource. Typically,
    # rights information includes a statement about various property rights
    # associated with the resource, including intellectual property rights.
    #
    # Example: "Content licensed under Creative Commons Attribution 3.0
    # United States License", "CC BY-SA"
    attr_accessor :rights
    
    # rightsHolder (http://purl.org/dc/terms/rightsHolder)
    #
    # @return [String]
    # A person or organization owning or managing rights over the resource.
    attr_accessor :rightsHolder

    # accessRights (http://purl.org/dc/terms/accessRights)
    #
    # @return [String]
    # Information about who can access the resource or an indication of its
    # security status. Access Rights may include information regarding
    # access or restrictions based on privacy, security, or other policies.
    #
    # Example: "not-for-profit use only"
    attr_accessor :accessRights

    # bibliographicCitation (http://purl.org/dc/terms/bibliographicCitation)
    #
    # @return [String]
    # Citation information specified by the data publisher. Citation
    # information is inherited downward by all child taxa if no other
    # citation is included. Citation information is NOT accumulated upward.
    # For example, one citation may be linked to a Mammalia entry and
    # generally applies to all mammal species but a different citation for a
    # child taxon, Primates, applies to all child primate taxa.
    #
    # Example: “van Soest, R. (2009). Leucandra fistulosa (Johnston, 1842).
    # In: Van Soest, R.W.M, Boury-Esnault, N., Hooper, J.N.A., Rützler, K,
    # de Voogd, N.J., Alvarez, B., Hajdu, E., Pisera, A.B., Vacelet, J.
    # Manconi, R., Schoenberg, C., Janussen, D., Tabachnick, K.R., 
    # Klautau, M. (Eds) (2009). World Porifera database”
    attr_accessor :bibliographicCitation

    # informationWithheld (http://rs.tdwg.org/dwc/terms/informationWithheld)
    #
    # @return [String]
    # Additional remarks as to information not published, but available
    #
    # Example: “hybrid parents information available”
    attr_accessor :informationWithheld
    
    # datasetID (http://rs.tdwg.org/dwc/terms/datasetID)
    #
    # @return [String]
    # An identifier for a (sub) dataset. Ideally globally unique, but any id
    # allowed
    #
    # Example: “13”
    attr_accessor :datasetID
    
    # datasetName (http://rs.tdwg.org/dwc/terms/datasetName)
    #
    # @return [String]
    # The title of the (sub)dataset optionally also referenced via datasetID
    #
    # Example: "World Register of Marine Species" "Fauna Europaea"
    attr_accessor :datasetName
    
    # source (http://purl.org/dc/terms/source)
    #
    # @return [String]
    # Used to link to an external representation of the data record such as
    # in a source web database. A URI link or reference to the source of this
    # record. A link to a webpage or RESTful webservice is recommended.
    # URI is mandatory format.
    #
    # Example: “http://www.catalogueoflife.org/annual-checklist/show_species_details.php?record_id=6197868”
    attr_accessor :source

  end
  
end