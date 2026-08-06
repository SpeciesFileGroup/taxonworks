<template>
  <div :class="['v-badge', colorClass, radiusClass]">
    <slot />
  </div>
</template>
<script setup>
import { computed } from 'vue'

defineOptions({ name: 'VBadge' })

const props = defineProps({
  color: {
    type: String,
    default: 'default'
  },

  radius: {
    type: String,
    default: 'xsmall',
    validator: (value) =>
      ['none', 'xsmall', 'small', 'medium', 'large', 'full'].includes(value)
  }
})

const colorClass = computed(() => `v-badge--${props.color}`)

const radiusClass = computed(() => `v-badge--radius-${props.radius}`)
</script>

<style>
.v-badge {
  padding: var(--spacing-xxs) var(--spacing-xs);
  border-radius: var(--border-radius-xsmall);
  font-size: var(--font-size-xs);
  width: min-content;
}

.v-badge--radius-none {
  border-radius: 0;
}

.v-badge--radius-xsmall {
  border-radius: var(--border-radius-xsmall);
}

.v-badge--radius-small {
  border-radius: var(--border-radius-small);
}

.v-badge--radius-medium {
  border-radius: var(--border-radius-medium);
}

.v-badge--radius-large {
  border-radius: var(--border-radius-large);
}

.v-badge--radius-full {
  border-radius: 9999px;
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
