// Unnamed OTUs (relying on the taxon name for their label) sort before named
// ones, so an ambiguous match's more generic OTUs surface first. Used for both
// display order and picking the default selectedOtuId, so the two stay consistent.
export default (otus) =>
  [...otus].sort((a, b) => (a.name ? 1 : 0) - (b.name ? 1 : 0))
