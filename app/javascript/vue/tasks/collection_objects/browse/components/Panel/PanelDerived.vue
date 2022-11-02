<template>
  <TableGrid
    :columns="2"
    :column-width="{
      default: 'min-content',
      0: '1fr',
      1: '1fr',
    }"
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
