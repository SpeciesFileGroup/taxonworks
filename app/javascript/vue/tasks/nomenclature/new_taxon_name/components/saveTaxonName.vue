<template>
  <button
    type="button"
    :disabled="!validateInfo || isSaving"
    @click="saveTaxon"
  >
    {{ taxon.id ? 'Save' : 'Create' }}
  </button>
</template>

<script setup>
import { computed, ref } from 'vue'
import { useStore } from 'vuex'
import { GetterNames } from '../store/getters/getters'
import { ActionNames } from '../store/actions/actions'
import platformKey from '@/helpers/getPlatformKey'
import useHotkey from 'vue3-hotkey'

const store = useStore()

const parent = computed(() => store.getters[GetterNames.GetParent])
const taxon = computed(() => store.getters[GetterNames.GetTaxon])
const validateInfo = computed(
  () =>
    parent.value &&
    taxon.value.name &&
    taxon.value.name.replace(' ', '').length >= 2
)

const isSaving = computed(() => store.getters[GetterNames.GetSaving])

const shortcuts = ref([
  {
    keys: [platformKey(), 's'],
    preventDefault: true,
    handler() {
      saveTaxon()
    }
  }
])

useHotkey(shortcuts.value)

function saveTaxon() {
  if (validateInfo.value && !isSaving.value) {
    if (taxon.value.id) {
      updateTaxonName()
    } else {
      createTaxonName()
    }
  }
}

function createTaxonName() {
  store.dispatch(ActionNames.CreateTaxonName, taxon.value).catch(() => {})
}

function updateTaxonName() {
  store.dispatch(ActionNames.UpdateTaxonName, taxon.value).catch(() => {})
}
</script>
