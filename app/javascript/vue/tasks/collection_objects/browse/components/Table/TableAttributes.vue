<template>
  <table>
    <thead>
      <tr class="cell-head">
        <th>Field</th>
        <th>Value</th>
      </tr>
    </thead>
    <tbody>
      <tr 
        v-for="(value, key) in items"
        :key="key"
      >
        <td>{{ key }}</td>
        <td
          class="cell-value"
          v-html="value"
        />
      </tr>
    </tbody>
  </table>
</template>

<script setup>
import { GetterNames } from '../../../store/getters/getters'
import { computed } from 'vue'
import { useStore } from 'vuex'
import PanelBufferedSection from './PanelBufferedSection.vue'

const store = useStore()

const collectionObject = computed(() => store.getters[GetterNames.GetCollectonObject])
</script>

<style scoped>
.cell-value {
  font-weight: 500;
}

.cell-head {
  text-transform: uppercase;
}
</style>