<template>
  <v-btn
    color="primary"
    medium
    @click="resetFilter"
    :disabled="!isFilterActive"
  >
    Reset filters
  </v-btn>
</template>

<script setup>

import { MutationNames } from '../store/mutations/mutations'
import { GetterNames } from '../store/getters/getters'
import { useStore } from 'vuex'
import { computed } from 'vue'
import VBtn from 'components/ui/VBtn/index.vue'

const store = useStore()

const filterState = computed(() => store.getters[GetterNames.GetParamsFilter])
const isFilterActive = computed(() => (Object.keys(filterState.value.filter).length || filterState.value.status.length))

const resetFilter = () => {
  const filterState = store.getters[GetterNames.GetParamsFilter]

  store.commit(MutationNames.SetParamsFilter, {
    ...filterState,
    filter: {},
    status: []
  })
}

</script>
