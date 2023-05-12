<template>
  <TableGrid
    :columns="1"
    :column-width="{ default: 'minmax(100px, auto)' }"
    gap="1em"
  >
    <PanelDwc />
    <PanelTimeline />
  </TableGrid>
</template>

<script setup>
import PanelTimeline from './PanelTimeline.vue'
import PanelDwc from './PanelDwc.vue'
import TableGrid from 'components/layout/Table/TableGrid.vue'
</script>
