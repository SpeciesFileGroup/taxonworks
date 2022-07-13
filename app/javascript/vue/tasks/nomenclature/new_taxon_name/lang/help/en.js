//  New taxon name
//  language: en

export default {
  section: {
    navbar: {
      autosave: 'Enable/disable autosave for taxon name. Relationships and status will use autosave without considering this configuration.',
      clone: 'Clone the current taxon name.',
      childIcon: 'Create a new taxon name with the same parent',
      sisterIcon: 'Create a child of this taxon name'
    },
    basic: {
      container: 'Use this section to provide the minimily require information, a name, parent, and rank. Rank is guessed based on parent, and can be adjusted if the guess in not correct.',
      name: 'A monominal.',
      parent: 'The parent of a taxon name is the location in a classification that you would expect to find this name <em>if nothing else is known</em>. <b>Parenthood never implies synonymy! For example, the parent of a synonymous species is the same as the parent its valid name.</b>'
    },
    author: {
      container: 'Use this section to provide the authorship authorship of the taxon name.  Authorship can be asserted in different ways.  If provided in more than one way the priority used is the first of Verbatim, Person, Source. The preferred mechanism assigning a source that has people assigned to it as authors.',
      source: 'Assign authorship via proxy to the authorship of a Source. The author name is taken from the verbatim author string of the source, or the Person who is assigned as an author of the source. If a source is selected and it includes both a verbatim author and an assigned person as author, then the verbatim value has priority. Assigning a source here creates an originating Citation. SubsequentMonotypy citations can be created via the radial annotator.',
      verbatim: 'Assign the authorship by direct reference to the name provide. Takes top priority.',
      person: 'Assign a person as the author. This is the preferred method if source can not be provided. New people can be created directly inline.'
    },
    etymology: {
      container: 'Provide the background as to how the taxon name came to be. Text can be styled using Markdown.'
    },
    type: {
      container: 'Assign the type of a genus or family group name (ICZN). For species names there is a link that allows a specimen to be created.'
    },
    status: {
      container: 'Use this section to assert a property of name <em>without refrence to another name</em>.  For example if the curator feels a name is unavailble, or invalid, but the valid name is not known this status can be used.'
    },
    relationship: {
      container: 'Use this section to define relationship between this name and any other name, for example synonym, homonym, etc.'
    },
    originalCombination: {
      container: 'If the current classification of this name differs from the classification of the name as it was originally published the latter can be defined here.  To initiate the original combination either 1) Click the use original, or 2) click and drag the name into the rank it was originally found it.  After initiating search and provide the rest of the epithet.'
    },
    classification: {
      container: 'Use this section to set the taxon as incertae sedis or to classify the source'
    }
  }
}
