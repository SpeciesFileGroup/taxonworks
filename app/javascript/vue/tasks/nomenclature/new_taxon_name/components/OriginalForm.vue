<template>
  <block-layout
    anchor="family-group-name-form"
    :spinner="!taxon.id"
  >
    <template #header>
      <h3>Original form</h3>
    </template>
    <template #body>
      <div class="field horizontal-left-content gap-small">
        <EditInPlace
          legend="Click to edit verbatim"
          v-model="verbatimName"
        />
      </div>
    </template>
  </block-layout>
</template>

<script setup>
import { computed } from 'vue'
import { useStore } from 'vuex'
import { MutationNames } from '../store/mutations/mutations.js'
import { GetterNames } from '../store/getters/getters'

import BlockLayout from '@/components/layout/BlockLayout'
import EditInPlace from '@/components/editInPlace.vue'

const store = useStore()
const taxon = computed(() => store.getters[GetterNames.GetTaxon])

const verbatimName = computed({
  get: () => taxon.value.verbatim_name,
  set: (value) => {
    taxon.value.verbatim_name = value
    store.commit(MutationNames.UpdateLastChange)
  }
})
</script>
