<template>
  <block-layout :warning="hasUnsavedChanges">
    <template #header>
      <h3>Type material</h3>
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

<script setup>
import { computed, ref, onBeforeMount } from 'vue'
import { useStore } from 'vuex'
import { GetterNames } from '../../store/getters/getters.js'
import { RouteNames } from '@/routes/routes.js'
import ActionNames from '../../store/actions/actionNames.js'
import TypeMaterialType from './TypeMaterialType.vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import platformKey from '@/helpers/getPlatformKey'
import TypeMaterialList from './TypeMaterialList.vue'
import TypeMaterialTaxon from './TypeMaterialTaxon.vue'
import TypeMaterialSource from './TypeMaterialSource.vue'
import TypeMaterialAdd from './TypeMaterialAdd.vue'
import { useHotkey } from '@/composables'

const OSKey = platformKey()
const store = useStore()

const shortcuts = ref([
  {
    keys: [OSKey, 'm'],
    handler() {
      switchToTask(RouteNames.TypeMaterial)
    }
  },
  {
    keys: [OSKey, 't'],
    handler() {
      switchToTask(RouteNames.NewTaxonName)
    }
  },
  {
    keys: [OSKey, 'o'],
    handler() {
      switchToTask(RouteNames.BrowseOtu)
    }
  },
  {
    keys: [OSKey, 'b'],
    handler() {
      switchToTask(RouteNames.BrowseNomenclature)
    }
  }
])

useHotkey(shortcuts.value)

const typeMaterial = computed(() => store.getters[GetterNames.GetTypeMaterial])
const hasUnsavedChanges = computed(() =>
  store.getters[GetterNames.GetTypeMaterials].some((item) => !item.isUnsaved)
)

function switchToTask(url) {
  const { protonymId } = typeMaterial.value
  const param = protonymId ? `?taxon_name_id=${protonymId}` : ''

  window.open(`${url}${param}`, '_self')
}

onBeforeMount(() => {
  const urlParams = new URLSearchParams(window.location.search)
  const taxonId = urlParams.get('taxon_name_id')

  if (/^\d+$/.test(taxonId)) {
    store.dispatch(ActionNames.SetTypeMaterialTaxonName, taxonId)
  }
})
</script>
