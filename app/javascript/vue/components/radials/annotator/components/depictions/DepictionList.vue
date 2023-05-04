<template>
  <table class="full_width">
    <thead>
      <tr>
        <th>Image</th>
        <th>Is data</th>
        <th>Label</th>
        <th>Caption</th>
        <th />
      </tr>
    </thead>
    <tbody>
      <DepictionListRow
        v-for="item in list"
        :key="item.id"
        :depiction="item"
        @delete="emit('delete', item)"
        @selected="emit('selected', item)"
        @update:label="
          (label) => emit('update:label', { ...item, figure_label: label })
        "
        @update:caption="
          (caption) => emit('update:caption', { ...item, caption })
        "
      />
    </tbody>
  </table>
</template>

<script setup>
import DepictionListRow from './DepictionListRow.vue'

defineProps({
  list: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits([
  'delete',
  'selected',
  'update:label',
  'update:caption'
])
</script>
