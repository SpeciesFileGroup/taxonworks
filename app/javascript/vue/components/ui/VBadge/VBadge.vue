<template>
  <div :class="['v-badge', colorClass]">
    <slot />
  </div>
</template>
<script setup>
import { computed } from 'vue'

const props = defineProps({
  color: {
    type: String,
    default: 'default'
  }
})

const colorClass = computed(() => `v-badge--${props.color}`)
</script>

<style scoped>
.v-badge {
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-size: 0.75rem;
  width: min-content;
}

.v-badge--default {
  background-color: var(--badge-default-bg);
  color: var(--badge-default-color);
}

.v-badge--blue {
  background-color: var(--badge-blue-bg);
  color: var(--badge-blue-color);
}

.v-badge--green {
  background-color: var(--badge-green-bg);
  color: var(--badge-green-color);
}

.v-badge--yellow {
  background-color: var(--badge-yellow-bg);
  color: var(--badge-yellow-color);
}

.v-badge--red {
  background-color: var(--badge-red-bg);
  color: var(--badge-red-color);
}

.v-badge--purple {
  background-color: var(--badge-purple-bg);
  color: var(--badge-purple-color);
}
</style>
