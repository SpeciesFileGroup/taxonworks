import { makeTaxonNode } from './makeTaxonNameNode'

export function makeTaxonNodeWithState(taxon) {
  return {
    ...makeTaxonNode(taxon),
    isLoaded: false,
    isExpanded: true
  }
}
