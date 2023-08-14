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
        <input
          type="text"
          placeholder="Type a name..."
          v-model="taxon.verbatim_name"
          @input="store.commit(MutationNames.UpdateLastChange)"
        />
        <VBtn
          color="update"
          medium
          @click="saveChanges"
        >
          Save
        </VBtn>
      </div>
    </template>
  </block-layout>
</template>

<script setup>
import { computed } from 'vue'
import { useStore } from 'vuex'
import { ActionNames } from '../store/actions/actions'
import { MutationNames } from '../store/mutations/mutations.js'
import { GetterNames } from '../store/getters/getters'
import VBtn from '@/components/ui/VBtn/index.vue'

import BlockLayout from '@/components/layout/BlockLayout'

const store = useStore()
const taxon = computed(() => store.getters[GetterNames.GetTaxon])

function saveChanges() {
  store.dispatch(ActionNames.UpdateTaxonName, taxon.value)
}
</script>
