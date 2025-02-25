<template>
  <BlockLayout>
    <template #header>
      <div class="flex-separate middle full_width">
        <h3>FieldOccurrence</h3>
      </div>
    </template>
    <template #body>
      <TableGrid :columns="1">
        <TableAttributes :items="attributes" />
      </TableGrid>
    </template>
  </BlockLayout>
</template>

<script setup>
import { computed } from 'vue'
import useStore from '../../store/store.js'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import TableAttributes from '../Table/TableAttributes.vue'
import TableGrid from '@/components/layout/Table/TableGrid.vue'

const store = useStore()

const attributes = computed(() => ({
  total: store.fieldOccurrence?.total,
  created_at: store.fieldOccurrence?.created_at,
  updated_at: store.fieldOccurrence?.updated_at
}))
</script>
