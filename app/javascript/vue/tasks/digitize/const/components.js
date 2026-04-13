import TypeMaterial from '../components/typeMaterial/TypeMaterialMain.vue'
import BiologicalAssociations from '../components/biologicalAssociation/main.vue'
import TaxonDetermination from '../components/taxonDetermination/main.vue'

const ComponentLeftColumn = {
  TaxonDeterminationLayout: 'TaxonDeterminationLayout',
  BiologicalAssociation: 'BiologicalAssociation',
  TypeMaterial: 'TypeMaterial'
}

const VueComponents = {
  [ComponentLeftColumn.TypeMaterial]: TypeMaterial,
  [ComponentLeftColumn.BiologicalAssociation]: BiologicalAssociations,
  [ComponentLeftColumn.TaxonDeterminationLayout]: TaxonDetermination
}

export { VueComponents, ComponentLeftColumn }
