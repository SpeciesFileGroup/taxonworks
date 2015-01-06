# Ultimately move this to a controlled vocabulary YAML reference, namespaced as well
#
# see http://www.w3.org/TR/skos-reference/#mapping 
SKOS_RELATIONS = { 
  'skos:broadMatch' => 'Broad match (implies a whole and parts, or hierarchical relation).',    
  'skos:narrowMatch' => 'Narrow match (implies a whole and parts, or hierarchical relation).',  
  'skos:relatedMatch' => 'Related match (an associative relation, neither more general nor specific).',
  'skos:closeMatch' => 'Close match (almost the same, but not interchangable).',  
  'skos:exactMatch' => 'Exact match (the same, interchangable)'
}
