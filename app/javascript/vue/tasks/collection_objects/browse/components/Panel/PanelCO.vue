<template>
  <TableGrid
    :columns="1"
    gap="1em"
  >
    <PanelBuffered />
    <TableGrid
      gap="1em"
      :columns="2"
      :column-width="{
        default: 'min-content',
        0: '1fr',
        1: '1fr',
      }"
    >
      <PanelIdentifier />
      <PanelBiocurations />
    </TableGrid>
  </TableGrid>
</template>

<script setup>
import PanelBuffered from './PanelBuffered/PanelBuffered.vue'

import PanelBiocurations from './PanelBiocurations.vue'
import TableGrid from 'components/layout/Table/TableGrid.vue'
</script>
