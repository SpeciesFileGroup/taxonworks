export default (taxon, children = []) => {
  return {
    id: taxon.id,
    name: taxon.label,
    synonyms: taxon.synonyms,
    leaf: taxon.leaf_node,
    isExpanded: false,
    isValid: taxon.is_valid,
    children: children || [],
    total: {
      valid: taxon.valid_descendants,
      invalid: taxon.invalid_descendants
    }
  }
}
