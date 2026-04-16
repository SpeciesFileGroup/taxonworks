<template>
  <div class="progress-bar horizontal-left-content">
    <div
      v-for="(value, key) in ImportColors"
      :key="key"
      :style="{
        backgroundColor: `var(${value})`,
        width: `${getPorcent(key)}%`
      }"
    />
  </div>
</template>

<script setup>
import { computed } from 'vue'
import ImportColors from '../const/importColors'

const props = defineProps({
  progress: {
    type: Object,
    default: () => ({})
  }
})

const totalCount = computed(() =>
  Object.values(props.progress).reduce(
    (accumulator, currentValue) => accumulator + currentValue
  )
)

function getPorcent(key) {
  return props.progress[key]
    ? (props.progress[key] * 100) / totalCount.value
    : 0
}
</script>

<style scoped>
.progress-bar {
  background-color: gray;
  height: 12px;
  overflow: hidden;
  border-radius: 6px;
  div {
    height: 12px;
  }
}
</style>
