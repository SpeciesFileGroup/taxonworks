//  New source task
//  language: en

export default {
  section: {
    sourceType: {
      BibTeX: "The citation is in BibTeX format, the default for TaxonWorks that gives you the most flexibility.",
      Verbatim: "The citation is a single field, with no parts broken out.",
      Person: "The citation is a person."
    },
    BibTeX: {
      type: 'Type is required for all records. Most will be "article".',
      authors: 'Find people, or create-new ones inline, assigning them to the role of SourceAuthor. You can drag drop people to reorder them.',
      year: 'If you have a single year, the value goes here. If you have two years, the actual year of publication goes here.',
      yearSuffix: 'The "a" of 1920a. Usage is recommend only for historical reference, new systems should depend advanced search, hyperlinks etc. to determine a sources identity.',
      yearStated: 'Use only if Year is provided, and it differs from the actual year of publication.  See Year.',
      month: 'Values are in format of legal BibTeX.',
      editors: 'Find people, or create-new ones inline, assigning them to the role of SourceEditor. You can drag drop people to reorder them.',
      crosslinks: 'These data are from BibTeX but variously automatically translated to normalized values in TW.',
      attributes: 'These are not BibTeX attributes. They are largely used in imports and are reflections of past databases.  Currently you should use Documentation for content, and Tags for keywords.',
      serial: 'Serials are repeated publications, most will know these as Journals.',

    },
    navBar: {
      crossRef: 'Use the DOI to get a semi-automated approach through Crossref to get parsed values of the source you are looking for.'
    }
  }
}
