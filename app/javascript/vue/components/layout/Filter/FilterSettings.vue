<template>
  <ul class="context-menu">
    <slot name="first" />
    <li>
      <label>
        <input
          type="checkbox"
          v-model="activeFilter"
        >
        Show filter
      </label>
    </li>
    <li>
      <label>
        <input
          type="checkbox"
          v-model="activeUrl"
        >
        Show JSON Request
      </label>
    </li>
    <li>
      <label>
        <input
          type="checkbox"
          v-model="activeAppend"
        >
        Append results
      </label>
    </li>
    <li>
      <label>
        <input
          type="checkbox"
          v-model="activeList"
        >
        Show list
      </label>
    </li>
    <slot name="last" />
  </ul>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  filter: {
    type: Boolean,
    default: undefined
  },

  url: {
    type: Boolean,
    default: undefined
  },

  append: {
    type: Boolean,
    default: undefined
  },

  list: {
    type: Boolean,
    default: undefined
  }
})

const emit = defineEmits([
  'update:filter',
  'update:url',
  'update:append',
  'update:list'
])

const activeFilter = computed({
  get: () => props.filter,
  set: value => emit('update:filter', value)
})

const activeUrl = computed({
  get: () => props.url,
  set: value => emit('update:url', value)
})

const activeAppend = computed({
  get: () => props.append,
  set: value => emit('update:append', value)
})

const activeList = computed({
  get: () => props.list,
  set: value => emit('update:list', value)
})
</script>
