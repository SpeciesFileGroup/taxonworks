export function makeTaxonNode(taxon) {
  return {
    id: taxon.id,
    name: taxon.label,
    synonyms: taxon.synonyms,
    leaf: taxon.leaf_node,
    isExpanded: false,
    isValid: taxon.is_valid,
    validId: taxon.cached_valid_taxon_name_id,
    children: taxon.children?.map((c) => makeTaxonNode(c)) || [],
    total: {
      valid: taxon.valid_descendants,
      invalid: taxon.invalid_descendants
    }
  }
}
