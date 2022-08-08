<template>
  <block-layout :warning="hasUnsavedChanges">
    <template #header>
      <h3 v-hotkey="shortcuts">
        Type material
      </h3>
    </template>
    <template #body>
      <div>
        <TypeMaterialTaxon />
        <TypeMaterialType />
        <TypeMaterialSource />
        <TypeMaterialAdd class="margin-small-top margin-small-bottom" />
        <TypeMaterialList />
      </div>
    </template>
  </block-layout>
</template>

<script>

import { GetterNames } from '../../store/getters/getters.js'
import ActionNames from '../../store/actions/actionNames.js'
import TypeMaterialType from './TypeMaterialType.vue'
import BlockLayout from 'components/layout/BlockLayout.vue'
import platformKey from 'helpers/getPlatformKey'
import TypeMaterialList from './TypeMaterialList.vue'
import TypeMaterialTaxon from './TypeMaterialTaxon.vue'
import TypeMaterialSource from './TypeMaterialSource.vue'
import TypeMaterialAdd from './TypeMaterialAdd.vue'

export default {
  components: {
    BlockLayout,
    TypeMaterialList,
    TypeMaterialTaxon,
    TypeMaterialType,
    TypeMaterialSource,
    TypeMaterialAdd
  },
  computed: {
    shortcuts () {
      const keys = {}

      keys[`${platformKey()}+m`] = this.switchTypeMaterial
      keys[`${platformKey()}+t`] = this.switchNewTaxonName
      keys[`${platformKey()}+o`] = this.switchBrowseOtu
      keys[`${platformKey()}+b`] = this.switchBrowseNomenclature

      return keys
    },

    typeMaterial () {
      return this.$store.getters[GetterNames.GetTypeMaterial]
    },

    hasUnsavedChanges () {
      return this.$store.getters[GetterNames.GetTypeMaterials].some(item => !item.isUnsaved)
    }
  },

  created () {
    const urlParams = new URLSearchParams(window.location.search)
    const taxonId = urlParams.get('taxon_name_id')

    if (/^\d+$/.test(taxonId)) {
      this.$store.dispatch(ActionNames.SetTypeMaterialTaxonName, taxonId)
    }
  },

  methods: {
    switchNewTaxonName () {
      window.open(`/tasks/nomenclature/new_taxon_name${this.taxon ? `?taxon_name_id=${this.taxon.id}` : ''}`, '_self')
    },

    switchBrowseNomenclature () {
      window.open(`/tasks/nomenclature/browse${this.taxon ? `?taxon_name_id=${this.taxon.id}` : ''}`, '_self')
    },

    switchTypeMaterial () {
      window.open(`/tasks/type_material/edit_type_material${this.taxon ? `?taxon_name_id=${this.taxon.id}` : ''}`, '_self')
    },

    switchBrowseOtu () {
      window.open(`/tasks/otus/browse${this.taxon ? `?taxon_name_id=${this.taxon.id}` : ''}`, '_self')
    }
  }
}
</script>
