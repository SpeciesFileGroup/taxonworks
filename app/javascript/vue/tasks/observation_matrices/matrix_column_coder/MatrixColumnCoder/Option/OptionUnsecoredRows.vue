<template>
  <label class="middle">
    <input
      type="checkbox"
      v-model="onlyUnsecored"
    >
    Display only unsecored rows
  </label>
</template>

<script setup>
import { computed } from 'vue'
import { useStore } from 'vuex'
import { MutationNames } from '../../store/mutations/mutations'
import { GetterNames } from '../../store/getters/getters'

const store = useStore()

const onlyUnsecored = computed({
  get: () => {
    return store.getters[GetterNames.GetDisplayUnsecoredRows]
  },

  set: value => {
    store.commit(MutationNames.SetDisplayOnlyUnsecored, value)
  }
})
</script>
