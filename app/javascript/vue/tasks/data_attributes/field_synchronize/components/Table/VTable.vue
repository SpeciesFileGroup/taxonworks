<template>
  <table
    class="table-striped full_width"
    border="1"
  >
    <thead>
      <tr>
        <th
          v-for="attr in attributes"
          :key="attr"
        >
          {{ attr }}
          <VBtn
            color="primary"
            circle
            @click="emit('remove:attribute', attr)"
          >
            <VIcon
              name="trash"
              x-small
            />
          </VBtn>
        </th>
      </tr>
    </thead>
    <tbody>
      <TableRow
        v-for="item in list"
        :key="item.id"
        :item="item"
        :attributes="attributes"
        :emit="emit"
        @update:attribute="(e) => emit('update:attribute', e)"
      />
    </tbody>
  </table>
</template>

<script setup>
import TableRow from './TableRow.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

const props = defineProps({
  attributes: {
    type: Array,
    default: () => []
  },

  list: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['remove:attribute', 'update:attribute'])
</script>
