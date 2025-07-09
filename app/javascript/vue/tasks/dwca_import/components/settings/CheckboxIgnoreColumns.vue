<template>
  <label class="flex flex-row middle cursor-pointer">
    <input
      type="checkbox"
      v-model="settings.ignoredColumns"
    />
    Show ignored columns
  </label>
</template>

<script setup>
import { useStore } from 'vuex'
import { computed } from 'vue'
import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'
const store = useStore()

const settings = computed({
  get: () => store.getters[GetterNames.GetSettings],
  set: (value) => store.commit(MutationNames.SetSettings, value)
})
</script>
