export function makeTaxonNode(taxon) {
  return {
    id: taxon.id,
    name: taxon.label,
    synonyms: taxon.synonyms,
    leaf: taxon.leaf_node,
    isExpanded: false,
    isValid: taxon.is_valid,
    children: taxon.children?.map((c) => makeTaxonNode(c)) || [],
    total: {
      valid: taxon.valid_descendants,
      invalid: taxon.invalid_descendants
    }
  }
}
