<template>
  <table class="full_width table-striped">
    <thead>
      <tr>
        <th>Image</th>
        <th>Is data</th>
        <th>Label</th>
        <th>Caption</th>
        <th class="w-4">Img</th>
        <th class="w-4" />
      </tr>
    </thead>
    <VDraggable
      v-model="list"
      item-key="id"
      tag="tbody"
      @change="() => emit('sort')"
    >
      <template #item="{ element }">
        <DepictionListRow
          :key="element.id"
          :depiction="element"
          @move="(item) => emit('move', item)"
          @delete="emit('delete', element)"
          @selected="emit('selected', element)"
          @update:label="
            (label) => emit('update:label', { ...element, figure_label: label })
          "
          @update:caption="
            (caption) => emit('update:caption', { ...element, caption })
          "
        />
      </template>
    </VDraggable>
  </table>
</template>

<script setup>
import DepictionListRow from './DepictionListRow.vue'
import VDraggable from 'vuedraggable'

const list = defineModel({
  type: Array,
  required: true
})

const emit = defineEmits([
  'delete',
  'move',
  'selected',
  'update:label',
  'update:caption',
  'sort'
])
</script>
