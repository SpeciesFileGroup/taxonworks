<template>
  <div
    class="flex flex-row gap-small middle margin-medium-top"
    v-if="legend.length"
  >
    <div
      v-for="type in legend"
      :key="type"
      class="flex flex-row middle gap-xsmall"
    >
      <div :class="['legend-square', LEGEND[type].background]" />
      <span>{{ LEGEND[type].label }}</span>
    </div>
  </div>
</template>

<script setup>
import { useStore } from 'vuex'
import { computed } from 'vue'
import { GetterNames } from '../../store/getters/getters.js'
import { LEGEND } from '../../const/legend.js'

const store = useStore()
const legend = computed(() => store.getters[GetterNames.GetLegend])
</script>

<style scoped>
.legend-square {
  border-radius: 0.125rem;
  width: 12px;
  height: 12px;
}
</style>
