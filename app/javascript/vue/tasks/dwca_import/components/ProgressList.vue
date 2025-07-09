<template>
  <ul class="no_bullets">
    <template v-if="tableMode">
      <li
        style="border-bottom: 1px solid var(--border-color)"
        class="flex-separate padding-small-top padding-small-bottom"
        v-for="(color, property) in ImportColors"
        :key="property"
      >
        <span>{{ property }}</span>
        <b :style="{ color: `var(${color})` }">{{
          showTotal(progress[property])
        }}</b>
      </li>
    </template>
    <template v-else>
      <li
        class="flex-separate"
        v-for="(color, property) in ImportColors"
        :key="property"
      >
        <span
          >{{ property }}:
          <b :style="{ color: `var(${color})` }">{{
            showTotal(progress[property])
          }}</b></span
        >
      </li>
    </template>
  </ul>
</template>

<script setup>
import ImportColors from '../const/importColors.js'

const props = defineProps({
  progress: {
    type: Object,
    required: true
  },
  tableMode: {
    type: Boolean,
    default: false
  }
})

function showTotal(count = 0) {
  return count
}
</script>
