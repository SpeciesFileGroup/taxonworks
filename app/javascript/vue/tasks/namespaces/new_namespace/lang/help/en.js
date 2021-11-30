//  New namespace
//  language: en

export default {
  namespace: {
    form: {
      name: "A human readable name for this Namespace. Should hint at the Namespace's origin.",
      institution: 'The organization, or person responsible for minting the Namespace. It is OK to create Namespaces for sets of identifiers for those sets that didn not have formal definitions, even if you are not a member of the Organization.  Namespaces help group data, they do not imply ownership.',
      short_name: 'The literal, unchanging component of the identifier.  If virtual, then a mnemonic to that will aid in selection of the Namespace within the user-interface.',
      verbatim_short_name: 'If the short name is already selected, then an alternate short name must be provided.  The literal string, used in export, search, etc. is then placed here.',
      delimiter: 'The character(s) placed between the short name (unchanging) and the identifier.',
      is_virtual: 'If a Namespace is virtual, then it is not included when exporting or "rendering" identifiers, only for creating sets of identifiers in TaxonWorks, and allowing things like "123" and "123" coming from differnt datasets to be kept seperate.',
    }
  }
}
